// lib/features/admin/screens/tenant_management_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/tenant.dart';
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

class _TenantManagementScreenState extends State<TenantManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Tenant> _tenants = [];
  List<Tenant> _filteredTenants = [];
  Set<String> _selectedTenants = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  
  // Filters
  bool _includeInactive = false;
  String _selectedSchoolType = 'All';
  String _sortBy = 'school_name';
  bool _sortAscending = true;
  
  final List<String> _schoolTypes = ['All', 'K-12', 'Elementary', 'Middle School', 'High School', 'University'];

  @override
  void initState() {
    super.initState();
    _loadTenants();
    _searchController.addListener(_filterTenants);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    // Apply sorting
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(hardDelete ? 'Tenant permanently deleted' : 'Tenant deactivated'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } else {
        throw Exception('Failed to delete tenant');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tenant reactivated successfully'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } else {
        throw Exception('Failed to reactivate tenant');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => TenantCreateDialog(
        onTenantCreated: () => _loadTenants(refresh: true),
      ),
    );
  }

  void _showEditDialog(Tenant tenant) {
    showDialog(
      context: context,
      builder: (context) => TenantEditDialog(
        tenant: tenant,
        onTenantUpdated: () => _loadTenants(refresh: true),
      ),
    );
  }

  void _showDetailsDialog(Tenant tenant) {
    showDialog(
      context: context,
      builder: (context) => TenantDetailsDialog(tenant: tenant),
    );
  }

  void _showStatsDialog(Tenant tenant) {
    showDialog(
      context: context,
      builder: (context) => stats.TenantStatsDialog(tenant: tenant),
    );
  }

  void _showBulkOperationsDialog() {
    showDialog(
      context: context,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildFiltersAndSearch(),
        const SizedBox(height: 16),
        _buildBulkActions(),
        const SizedBox(height: 16),
        _buildContent(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tenant Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage schools and educational institutions',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _showCreateDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add School'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersAndSearch() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search schools, principals, or addresses...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: _selectedSchoolType,
          items: _schoolTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSchoolType = value!;
            });
            _filterTenants();
          },
        ),
        const SizedBox(width: 16),
        FilterChip(
          label: Text(_includeInactive ? 'Show All' : 'Active Only'),
          selected: _includeInactive,
          onSelected: (selected) {
            setState(() {
              _includeInactive = selected;
            });
            _loadTenants(refresh: true);
          },
          selectedColor: AppTheme.lightGreen,
        ),
        const SizedBox(width: 16),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (value) {
            setState(() {
              if (_sortBy == value) {
                _sortAscending = !_sortAscending;
              } else {
                _sortBy = value;
                _sortAscending = true;
              }
            });
            _filterTenants();
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'school_name', child: Text('Sort by Name')),
            const PopupMenuItem<String>(value: 'created_at', child: Text('Sort by Date')),
            const PopupMenuItem<String>(value: 'total_students', child: Text('Sort by Students')),
            const PopupMenuItem<String>(value: 'capacity_utilization', child: Text('Sort by Capacity')),
          ],
        ),
      ],
    );
  }

  Widget _buildBulkActions() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _selectedTenants.isNotEmpty ? 56 : 0,
      child: _selectedTenants.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.lightGreen),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedTenants.length} selected',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedTenants.clear()),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showBulkOperationsDialog,
                    icon: const Icon(Icons.settings),
                    label: const Text('Bulk Actions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _filteredTenants.isEmpty
                  ? _buildEmptyState()
                  : _buildTenantsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadTenants(refresh: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No schools found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Start by adding your first school',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add School'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantsList() {
    return ListView.builder(
      itemCount: _filteredTenants.length + (_hasMoreData ? 1 : 0),
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
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _loadTenants(),
        child: const Text('Load More'),
      ),
    );
  }

  Widget _buildTenantCard(Tenant tenant) {
    final bool isSelected = _selectedTenants.contains(tenant.id);
    final bool isOverCapacity = tenant.isOverCapacity;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected 
            ? BorderSide(color: AppTheme.primaryGreen, width: 2) 
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Checkbox(
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
                  activeColor: AppTheme.primaryGreen,
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: tenant.isActive 
                        ? AppTheme.lightGreen.withOpacity(0.2) 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.school,
                    color: tenant.isActive ? AppTheme.primaryGreen : Colors.grey[600],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tenant.schoolName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusChip(tenant),
                          if (isOverCapacity) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Over Capacity',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tenant.address,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Text(
                        'Principal: ${tenant.principalName}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
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
                    const PopupMenuItem<String>(value: 'details', child: Text('View Details')),
                    const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem<String>(value: 'stats', child: Text('Statistics')),
                    if (tenant.isActive)
                      const PopupMenuItem<String>(value: 'deactivate', child: Text('Deactivate'))
                    else
                      const PopupMenuItem<String>(value: 'reactivate', child: Text('Reactivate')),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete Permanently', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatItem('Students', '${tenant.totalStudents}', Icons.people, Colors.blue)),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(child: _buildStatItem('Teachers', '${tenant.totalTeachers}', Icons.person_2, Colors.green)),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(child: _buildStatItem('Capacity', '${tenant.capacityUtilization.toStringAsFixed(1)}%', Icons.donut_small, Colors.orange)),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(child: _buildStatItem('Type', tenant.schoolType, Icons.category, Colors.purple)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Tenant tenant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tenant.isActive ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tenant.statusText,
        style: TextStyle(
          color: tenant.isActive ? Colors.green[700] : Colors.red[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmation(Tenant tenant) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to permanently delete "${tenant.schoolName}"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone and will remove all associated data.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
