// lib/features/admin/screens/tenant_management_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/tenant.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/tenant_create_dialog.dart';
import '../widgets/tenant_edit_dialog.dart';
import '../widgets/tenant_details_dialog.dart';
import '../widgets/tenant_stats_dialog.dart' as stats;
import '../widgets/bulk_operations_dialog.dart';

class TenantManagementScreen extends StatefulWidget {
  const TenantManagementScreen({super.key});

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Tenant> _tenants = [];
  List<Tenant> _filteredTenants = [];
  Set<String> _selectedTenants = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  
  bool _includeInactive = false;
  String _selectedSchoolType = 'All';
  String _sortBy = 'school_name';
  bool _sortAscending = true;
  
  final List<String> _schoolTypes = ['All', 'K-12', 'Elementary', 'Middle School', 'High School', 'University'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadTenants();
    _searchController.addListener(_filterTenants);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (_hasMoreData && !_isLoadingMore) {
        _loadTenants();
      }
    }
  }

  Future<void> _loadTenants({bool refresh = false}) async {
    if (!mounted) return;

    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _tenants.clear();
      _selectedTenants.clear();
    }

    setState(() {
      if (refresh) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/v1/tenants/').replace(
        queryParameters: {
          'page': _currentPage.toString(),
          'size': _pageSize.toString(),
          'include_inactive': _includeInactive.toString(),
        },
      );
      
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        
        List<dynamic> newTenantsData;
        
        if (decodedResponse is Map<String, dynamic>) {
          if (decodedResponse.containsKey('items')) {
            newTenantsData = decodedResponse['items'] as List<dynamic>;
            final int totalItems = decodedResponse['total'] ?? 0;
            final int totalPages = (totalItems / _pageSize).ceil();
            _hasMoreData = _currentPage < totalPages;
          } else {
            throw Exception('Unexpected response format');
          }
        } else if (decodedResponse is List<dynamic>) {
          newTenantsData = decodedResponse;
          _hasMoreData = false;
        } else {
          throw Exception('Unexpected response format');
        }

        final List<Tenant> newTenants = newTenantsData
            .map((json) => Tenant.fromJson(json))
            .toList();

        if (refresh) {
          _tenants = newTenants;
        } else {
          _tenants.addAll(newTenants);
        }
        
        _filterTenants();
        _currentPage++;
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      if (!mounted) return;
      _error = 'Network error: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _filterTenants() {
    if (!mounted) return;

    final query = _searchController.text.toLowerCase();
    List<Tenant> filtered = _tenants.where((tenant) {
      final matchesSearch = tenant.schoolName.toLowerCase().contains(query) ||
                           tenant.address.toLowerCase().contains(query) ||
                           tenant.principalName.toLowerCase().contains(query) ||
                           tenant.email.toLowerCase().contains(query);
      
      final matchesType = _selectedSchoolType == 'All' || tenant.schoolType == _selectedSchoolType;
      
      return matchesSearch && matchesType;
    }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'school_name':
          comparison = a.schoolName.compareTo(b.schoolName);
          break;
        case 'created_at':
          comparison = (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
          break;
        case 'total_students':
          comparison = a.totalStudents.compareTo(b.totalStudents);
          break;
        case 'capacity_utilization':
          comparison = a.capacityUtilization.compareTo(b.capacityUtilization);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredTenants = filtered;
    });
  }

  Future<void> _deleteTenant(String tenantId, {bool hardDelete = false}) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/v1/tenants/$tenantId').replace(
        queryParameters: hardDelete ? {'hard_delete': 'true'} : null,
      );
      
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        await _loadTenants(refresh: true);
        if (mounted) {
          _showSuccessSnackBar(hardDelete ? 'Tenant permanently deleted' : 'Tenant deactivated');
        }
      } else {
        throw Exception('Failed to delete tenant');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  Future<void> _reactivateTenant(String tenantId) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/v1/tenants/$tenantId/reactivate');
      final response = await http.patch(uri);

      if (response.statusCode == 200) {
        await _loadTenants(refresh: true);
        if (mounted) {
          _showSuccessSnackBar('Tenant reactivated successfully');
        }
      } else {
        throw Exception('Failed to reactivate tenant');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius6),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius6),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      barrierColor: AppTheme.surfaceOverlay,
      builder: (context) => TenantCreateDialog(
        onTenantCreated: () => _loadTenants(refresh: true),
      ),
    );
  }

  void _showEditDialog(Tenant tenant) {
    showDialog(
      context: context,
      barrierColor: AppTheme.surfaceOverlay,
      builder: (context) => TenantEditDialog(
        tenant: tenant,
        onTenantUpdated: () => _loadTenants(refresh: true),
      ),
    );
  }

  void _showDetailsDialog(Tenant tenant) {
    showDialog(
      context: context,
      barrierColor: AppTheme.surfaceOverlay,
      builder: (context) => TenantDetailsDialog(tenant: tenant),
    );
  }

  void _showStatsDialog(Tenant tenant) {
    showDialog(
      context: context,
      barrierColor: AppTheme.surfaceOverlay,
      builder: (context) => stats.TenantStatsDialog(tenant: tenant),
    );
  }

  void _showBulkOperationsDialog() {
    showDialog(
      context: context,
      barrierColor: AppTheme.surfaceOverlay,
      builder: (context) => BulkOperationsDialog(
        selectedTenantIds: _selectedTenants.toList(),
        onOperationComplete: () {
          _selectedTenants.clear();
          _loadTenants(refresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for proper sizing
    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenSize.height - statusBarHeight;
    
    return Material(
      color: AppTheme.backgroundPrimary,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SizedBox(
            width: screenSize.width,
            height: availableHeight,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Fixed Header
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),
                
                // Fixed Controls
                SliverToBoxAdapter(
                  child: _buildFiltersAndSearch(),
                ),
                
                SliverToBoxAdapter(
                  child: _buildBulkActions(),
                ),
                
                // Content
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: availableHeight - 140, // Reserve space for fixed elements
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tenant Management',
                  style: AppTheme.headingSmall.copyWith(color: Colors.white),
                ),
                Text(
                  'Manage schools and institutions',
                  style: AppTheme.bodyMicro.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _showCreateDialog,
            borderRadius: AppTheme.borderRadius6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: AppTheme.borderRadius6,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    'Add School',
                    style: AppTheme.bodyMicro.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Search Bar
          SizedBox(
            height: 32,
            child: TextField(
              controller: _searchController,
              style: AppTheme.bodyMicro,
              decoration: InputDecoration(
                hintText: 'Search schools...',
                hintStyle: AppTheme.bodyMicro.copyWith(color: AppTheme.neutral400),
                prefixIcon: Icon(Icons.search, color: AppTheme.greenPrimary, size: 14),
                border: OutlineInputBorder(
                  borderRadius: AppTheme.borderRadius6,
                  borderSide: BorderSide(color: AppTheme.neutral300, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppTheme.borderRadius6,
                  borderSide: BorderSide(color: AppTheme.neutral300, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppTheme.borderRadius6,
                  borderSide: BorderSide(color: AppTheme.greenPrimary, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _selectedTenants.isNotEmpty ? 30 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: _selectedTenants.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: AppTheme.getMicroDecoration(
                color: AppTheme.green50,
                border: Border.all(color: AppTheme.greenPrimary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.checklist, size: 12, color: AppTheme.greenPrimary),
                  const SizedBox(width: 4),
                  Text(
                    '${_selectedTenants.length} selected',
                    style: AppTheme.bodyMicro.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.greenPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _selectedTenants.clear()),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Clear', style: AppTheme.bodyMicro),
                  ),
                  ElevatedButton(
                    onPressed: _showBulkOperationsDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Actions', style: AppTheme.bodyMicro.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildLoadingState();
    if (_error != null) return _buildErrorState();
    if (_filteredTenants.isEmpty) return _buildEmptyState();
    return _buildTenantsList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: AppTheme.greenPrimary, strokeWidth: 2),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading tenants...',
            style: AppTheme.bodyMicro.copyWith(color: AppTheme.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.getMicroDecoration(
          color: AppTheme.error.withOpacity(0.1),
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 24, color: AppTheme.error),
            const SizedBox(height: 8),
            Text(
              'Failed to load tenants',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.error),
            ),
            const SizedBox(height: 6),
            Text(
              _error!,
              style: AppTheme.bodyMicro.copyWith(color: AppTheme.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _loadTenants(refresh: true),
              style: AppTheme.smallButtonStyle,
              child: Text('Retry', style: AppTheme.bodyMicro.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.getMicroDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: AppTheme.borderRadius10,
              ),
              child: Icon(Icons.school_outlined, size: 32, color: AppTheme.neutral400),
            ),
            const SizedBox(height: 8),
            Text(
              'No schools found',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 4),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'Add your first school to get started',
              style: AppTheme.bodyMicro.copyWith(color: AppTheme.neutral500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showCreateDialog,
              style: AppTheme.smallButtonStyle,
              child: Text('Add School', style: AppTheme.bodyMicro.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _filteredTenants.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredTenants.length) {
          return _buildLoadMoreWidget();
        }
        
        final tenant = _filteredTenants[index];
        return _buildTenantCard(tenant);
      },
    );
  }

  Widget _buildLoadMoreWidget() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              color: AppTheme.greenPrimary,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Loading more...',
            style: AppTheme.bodyMicro.copyWith(color: AppTheme.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantCard(Tenant tenant) {
    final bool isSelected = _selectedTenants.contains(tenant.id);
    
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _showDetailsDialog(tenant),
        borderRadius: AppTheme.borderRadius8,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: AppTheme.getMicroDecoration(
            color: isSelected ? AppTheme.green50 : null,
            border: Border.all(
              color: isSelected 
                  ? AppTheme.greenPrimary.withOpacity(0.5) 
                  : AppTheme.neutral200.withOpacity(0.5),
              width: isSelected ? 1 : 0.5,
            ),
          ),
          child: Row(
            children: [
              // Selection checkbox
              Transform.scale(
                scale: 0.7,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedTenants.add(tenant.id);
                      } else {
                        _selectedTenants.remove(tenant.id);
                      }
                    });
                  },
                  activeColor: AppTheme.greenPrimary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              
              // School icon
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: tenant.isActive ? AppTheme.green50 : AppTheme.neutral100,
                  borderRadius: AppTheme.borderRadius6,
                ),
                child: Icon(
                  Icons.school,
                  color: tenant.isActive ? AppTheme.greenPrimary : AppTheme.neutral600,
                  size: 12,
                ),
              ),
              
              const SizedBox(width: 6),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tenant.schoolName,
                            style: AppTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(tenant),
                      ],
                    ),
                    Text(
                      tenant.address,
                      style: TextStyle(
                        fontSize: 8,
                        color: AppTheme.neutral600,
                        fontFamily: AppTheme.interFontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Principal: ${tenant.principalName}',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppTheme.neutral500,
                        fontFamily: AppTheme.interFontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Stats Row
                    Row(
                      children: [
                        _buildStatBadge('${tenant.totalStudents}', Icons.people, AppTheme.info),
                        const SizedBox(width: 4),
                        _buildStatBadge('${tenant.totalTeachers}', Icons.person, AppTheme.success),
                        const SizedBox(width: 4),
                        _buildStatBadge('${tenant.capacityUtilization.toStringAsFixed(1)}%', Icons.donut_small, AppTheme.warning),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions menu
              _buildActionsMenu(tenant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Tenant tenant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: tenant.isActive ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
        borderRadius: AppTheme.borderRadius6,
        border: Border.all(
          color: tenant.isActive ? AppTheme.success.withOpacity(0.3) : AppTheme.error.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        tenant.statusText,
        style: TextStyle(
          fontSize: 7,
          color: tenant.isActive ? AppTheme.success : AppTheme.error,
          fontWeight: FontWeight.w600,
          fontFamily: AppTheme.bauhausFontFamily,
        ),
      ),
    );
  }

  Widget _buildStatBadge(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.borderRadius6,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 8),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: AppTheme.bauhausFontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(Tenant tenant) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 14, color: AppTheme.neutral600),
      padding: const EdgeInsets.all(2),
      onSelected: (value) async {
        switch (value) {
          case 'details':
            _showDetailsDialog(tenant);
            break;
          case 'edit':
            _showEditDialog(tenant);
            break;
          case 'stats':
            _showStatsDialog(tenant);
            break;
          case 'deactivate':
            await _deleteTenant(tenant.id);
            break;
          case 'reactivate':
            await _reactivateTenant(tenant.id);
            break;
          case 'delete':
            final confirm = await _showDeleteConfirmation(tenant);
            if (confirm == true) {
              await _deleteTenant(tenant.id, hardDelete: true);
            }
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 12, color: AppTheme.info),
              const SizedBox(width: 4),
              Text('Details', style: AppTheme.bodyMicro),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 12, color: AppTheme.warning),
              const SizedBox(width: 4),
              Text('Edit', style: AppTheme.bodyMicro),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'stats',
          child: Row(
            children: [
              Icon(Icons.analytics, size: 12, color: AppTheme.greenPrimary),
              const SizedBox(width: 4),
              Text('Stats', style: AppTheme.bodyMicro),
            ],
          ),
        ),
        if (tenant.isActive)
          PopupMenuItem(
            value: 'deactivate',
            child: Row(
              children: [
                Icon(Icons.visibility_off, size: 12, color: AppTheme.neutral600),
                const SizedBox(width: 4),
                Text('Deactivate', style: AppTheme.bodyMicro),
              ],
            ),
          )
        else
          PopupMenuItem(
            value: 'reactivate',
            child: Row(
              children: [
                Icon(Icons.visibility, size: 12, color: AppTheme.success),
                const SizedBox(width: 4),
                Text('Reactivate', style: AppTheme.bodyMicro),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_forever, size: 12, color: AppTheme.error),
              const SizedBox(width: 4),
              Text('Delete', style: AppTheme.bodyMicro.copyWith(color: AppTheme.error)),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmation(Tenant tenant) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppTheme.surfaceOverlay,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 20, color: AppTheme.error),
            const SizedBox(height: 8),
            Text(
              'Confirm Deletion',
              style: AppTheme.labelMedium.copyWith(color: AppTheme.error),
            ),
            const SizedBox(height: 4),
            Text(
              'Delete "${tenant.schoolName}"?',
              style: AppTheme.bodyMicro.copyWith(color: AppTheme.neutral700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: AppTheme.bodyMicro),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Delete',
                      style: AppTheme.bodyMicro.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
