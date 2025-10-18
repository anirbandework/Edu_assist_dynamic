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

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

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
    _animationController?.dispose();
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
      parent: _animationController!,
      curve: Curves.easeOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController?.forward();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (_hasMoreData && !_isLoadingMore) {
        _loadTenants();
      }
    }
  }

  // Keep all your API methods exactly the same...
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
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius8),
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
            Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius8),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get exact screen dimensions to prevent infinite constraints
    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenSize.height - statusBarHeight;

    if (_animationController == null || _fadeAnimation == null) {
      return Container(
        width: screenSize.width,
        height: availableHeight,
        color: AppTheme.backgroundPrimary,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: screenSize.width,
      height: availableHeight,
      color: AppTheme.backgroundPrimary,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation!,
          child: Column(
            children: [
              // Header Section - Compact
              _buildHeader(),
              // Search Section - Compact
              _buildSearchSection(),
              // Bulk Actions (if any selected)
              if (_selectedTenants.isNotEmpty) _buildBulkActions(),
              // Main Content - Takes remaining space
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tenant Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Compact but readable
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage schools and institutions',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14, // Compact
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showCreateDialog(),
              borderRadius: AppTheme.borderRadius12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: AppTheme.borderRadius12,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Add School',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.neutral200, width: 0.5),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 15), // Compact but readable
        decoration: InputDecoration(
          hintText: 'Search schools by name, address, or principal...',
          hintStyle: TextStyle(color: AppTheme.neutral400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppTheme.greenPrimary, size: 20),
          filled: true,
          fillColor: AppTheme.neutral50,
          border: OutlineInputBorder(
            borderRadius: AppTheme.borderRadius12,
            borderSide: BorderSide(color: AppTheme.neutral300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTheme.borderRadius12,
            borderSide: BorderSide(color: AppTheme.neutral300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTheme.borderRadius12,
            borderSide: BorderSide(color: AppTheme.greenPrimary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBulkActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.getCompactDecoration(
        color: AppTheme.green50,
        border: Border.all(color: AppTheme.greenPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.checklist, size: 20, color: AppTheme.greenPrimary),
          const SizedBox(width: 8),
          Text(
            '${_selectedTenants.length} selected',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.greenPrimary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _selectedTenants.clear()),
            child: Text('Clear', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _showBulkOperationsDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.greenPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text('Actions', style: TextStyle(fontSize: 13, color: Colors.white)),
          ),
        ],
      ),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.greenPrimary.withOpacity(0.1),
              borderRadius: AppTheme.borderRadius12,
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.greenPrimary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading schools...',
            style: TextStyle(
              color: AppTheme.neutral600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.getCompactDecoration(
          color: AppTheme.error.withOpacity(0.1),
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: AppTheme.borderRadius12,
              ),
              child: Icon(Icons.error_outline, size: 40, color: AppTheme.error),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load tenants',
              style: TextStyle(
                color: AppTheme.error,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: AppTheme.neutral600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadTenants(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.greenPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.getCompactDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: AppTheme.borderRadius12,
              ),
              child: Icon(Icons.school_outlined, size: 48, color: AppTheme.neutral400),
            ),
            const SizedBox(height: 16),
            Text(
              'No schools found',
              style: TextStyle(
                color: AppTheme.neutral600,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search terms or clear the search.'
                  : 'Add your first school to get started.',
              style: TextStyle(
                color: AppTheme.neutral500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_searchController.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _filterTenants();
                },
                child: Text('Clear Search', style: TextStyle(fontSize: 14)),
              )
            else
              ElevatedButton(
                onPressed: () => _showCreateDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greenPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text('Add School', style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppTheme.greenPrimary,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more...',
            style: TextStyle(
              color: AppTheme.neutral600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantCard(Tenant tenant) {
    final bool isSelected = _selectedTenants.contains(tenant.id);
    final bool isInactive = !tenant.isActive;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailsDialog(tenant),
          borderRadius: AppTheme.borderRadius12,
          child: Container(
            padding: const EdgeInsets.all(16), // Comfortable padding
            decoration: AppTheme.getCompactDecoration(
              color: isSelected 
                  ? AppTheme.green50 
                  : isInactive 
                      ? AppTheme.neutral50.withOpacity(0.5)
                      : AppTheme.surfacePrimary,
              border: Border.all(
                color: isSelected 
                    ? AppTheme.greenPrimary.withOpacity(0.5)
                    : isInactive 
                        ? AppTheme.neutral300 
                        : AppTheme.neutral200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Opacity(
              opacity: isInactive ? 0.6 : 1.0,
              child: Row(
                children: [
                  // Selection checkbox
                  Transform.scale(
                    scale: 1.0,
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
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // School icon
                  Container(
                    width: 48, // Balanced size
                    height: 48,
                    decoration: AppTheme.getCompactDecoration(
                      color: isInactive ? AppTheme.neutral300 : AppTheme.green50,
                      borderRadius: AppTheme.borderRadius12,
                    ),
                    child: Icon(
                      Icons.school,
                      size: 24, // Balanced icon size
                      color: isInactive ? AppTheme.neutral600 : AppTheme.greenPrimary,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tenant.schoolName,
                                style: TextStyle(
                                  fontSize: 16, // Comfortable reading size
                                  fontWeight: FontWeight.bold,
                                  color: isInactive ? AppTheme.neutral600 : AppTheme.neutral900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isInactive) _buildStatusChip(tenant),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tenant.address,
                          style: TextStyle(
                            color: AppTheme.neutral600,
                            fontSize: 13, // Compact but readable
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (tenant.principalName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Principal: ${tenant.principalName}',
                            style: TextStyle(
                              color: AppTheme.neutral500,
                              fontSize: 12, // Compact
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Stats Row
                        Row(
                          children: [
                            _buildStatBadge('${tenant.totalStudents}', Icons.people, AppTheme.info),
                            const SizedBox(width: 8),
                            _buildStatBadge('${tenant.totalTeachers}', Icons.person, AppTheme.success),
                            const SizedBox(width: 8),
                            _buildStatBadge('${tenant.capacityUtilization.toStringAsFixed(1)}%', Icons.donut_small, AppTheme.warning),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Actions menu
                  _buildActionsMenu(tenant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Tenant tenant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tenant.isActive ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
        borderRadius: AppTheme.borderRadius8,
        border: Border.all(
          color: tenant.isActive ? AppTheme.success.withOpacity(0.3) : AppTheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        tenant.statusText,
        style: TextStyle(
          fontSize: 11, // Compact
          color: tenant.isActive ? AppTheme.success : AppTheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatBadge(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.borderRadius8,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14), // Balanced icon size
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11, // Compact but readable
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(Tenant tenant) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20, color: AppTheme.neutral600),
      padding: const EdgeInsets.all(4),
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
              Icon(Icons.visibility, size: 18, color: AppTheme.info),
              const SizedBox(width: 12),
              Text('Details', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18, color: AppTheme.warning),
              const SizedBox(width: 12),
              Text('Edit', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'stats',
          child: Row(
            children: [
              Icon(Icons.analytics, size: 18, color: AppTheme.greenPrimary),
              const SizedBox(width: 12),
              Text('Stats', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        if (tenant.isActive)
          PopupMenuItem(
            value: 'deactivate',
            child: Row(
              children: [
                Icon(Icons.visibility_off, size: 18, color: AppTheme.neutral600),
                const SizedBox(width: 12),
                Text('Deactivate', style: TextStyle(fontSize: 14)),
              ],
            ),
          )
        else
          PopupMenuItem(
            value: 'reactivate',
            child: Row(
              children: [
                Icon(Icons.visibility, size: 18, color: AppTheme.success),
                const SizedBox(width: 12),
                Text('Reactivate', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_forever, size: 18, color: AppTheme.error),
              const SizedBox(width: 12),
              Text('Delete', style: TextStyle(fontSize: 14, color: AppTheme.error)),
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
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 40, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              'Confirm Deletion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Delete "${tenant.schoolName}"?',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.neutral700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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

  // Keep all dialog methods exactly the same...
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
}
