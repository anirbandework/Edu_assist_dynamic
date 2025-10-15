// lib/features/screens/school_selection_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/models/tenant.dart';
import '../../shared/widgets/search_bar_widget.dart';

class SchoolSelectionScreen extends StatefulWidget {
  const SchoolSelectionScreen({super.key});

  @override
  State<SchoolSelectionScreen> createState() => _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState extends State<SchoolSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Tenant> _schools = [];
  List<Tenant> _filteredSchools = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  
  // Pagination variables
  int _currentPage = 1;
  final int _pageSize = 50;
  bool _hasMoreData = true;
  bool _includeInactive = false;

  @override
  void initState() {
    super.initState();
    _loadSchools();
    _searchController.addListener(_filterSchools);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools({bool refresh = false}) async {
    if (!mounted) return;

    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _schools.clear();
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
        
        List<dynamic> newSchoolsData;
        
        if (decodedResponse is Map<String, dynamic>) {
          if (decodedResponse.containsKey('items')) {
            newSchoolsData = decodedResponse['items'] as List<dynamic>;
            final int totalItems = decodedResponse['total'] ?? 0;
            final int totalPages = (totalItems / _pageSize).ceil();
            _hasMoreData = _currentPage < totalPages;
          } else {
            throw Exception('Unexpected response format: Map without items key');
          }
        } else if (decodedResponse is List<dynamic>) {
          newSchoolsData = decodedResponse;
          _hasMoreData = false;
        } else {
          throw Exception('Unexpected response format: ${decodedResponse.runtimeType}');
        }

        final List<Tenant> newSchools = newSchoolsData
            .map((json) => Tenant.fromJson(json))
            .toList();

        if (refresh) {
          _schools = newSchools;
        } else {
          _schools.addAll(newSchools);
        }
        
        _filteredSchools = _schools;
        _currentPage++;
        
        if (_searchController.text.isNotEmpty) {
          _filterSchools();
        }
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

  Future<void> _loadMoreSchools() async {
    if (!_hasMoreData || _isLoadingMore) return;
    await _loadSchools();
  }

  void _filterSchools() {
    if (!mounted) return;

    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSchools = _schools.where((school) {
        return school.schoolName.toLowerCase().contains(query) ||
               school.address.toLowerCase().contains(query) ||
               school.principalName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleIncludeInactive() {
    setState(() {
      _includeInactive = !_includeInactive;
    });
    _loadSchools(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select School'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.homeRoute),
        ),
        actions: [
          IconButton(
            icon: Icon(_includeInactive ? Icons.visibility : Icons.visibility_off),
            onPressed: _toggleIncludeInactive,
            tooltip: _includeInactive ? 'Hide Inactive Schools' : 'Show Inactive Schools',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadSchools(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Search schools...',
            ),
          ),

          // Include Inactive Toggle Info
          if (_includeInactive)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Showing active and inactive schools',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Content Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadSchools(refresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredSchools.isEmpty
                        ? _buildEmptyState()
                        : _buildSchoolsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredSchools.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredSchools.length) {
          return _buildLoadMoreWidget();
        }
        
        final school = _filteredSchools[index];
        return _buildSchoolCard(school);
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
        onPressed: _loadMoreSchools,
        child: const Text('Load More Schools'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No schools found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search terms'
                : _includeInactive
                    ? 'No schools available'
                    : 'Try including inactive schools',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolCard(Tenant school) {
    final bool isInactive = !school.isActive;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isInactive ? null : () => _selectSchool(school),
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isInactive ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // School Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isInactive 
                        ? Colors.grey[300]
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school,
                    size: 30,
                    color: isInactive 
                        ? Colors.grey[600]
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(width: 16),

                // School Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              school.schoolName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isInactive ? Colors.grey[600] : null,
                              ),
                            ),
                          ),
                          if (isInactive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        school.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (school.principalName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Principal: ${school.principalName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      // School stats
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${school.totalStudents} students',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.category, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            school.schoolType,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (!isInactive)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectSchool(Tenant school) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Your Role at ${school.schoolName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleOption('Student', Icons.person, () {
              Navigator.pop(context);
              _showLoginDialog(school, 'student');
            }),
            _buildRoleOption('Teacher', Icons.person_2, () {
              Navigator.pop(context);
              _showLoginDialog(school, 'teacher');
            }),
            _buildRoleOption('School Authority', Icons.admin_panel_settings, () {
              Navigator.pop(context);
              _showLoginDialog(school, 'admin');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(role),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showLoginDialog(Tenant school, String role) {
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;
          String? errorMessage;
          
          return AlertDialog(
            title: Text('Login as ${_getRoleDisplayName(role)}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Role Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      _getRoleIcon(role),
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // School Info
                  Text(
                    school.schoolName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (school.schoolCode != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'School Code: ${school.schoolCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // ID Input Field
                  TextFormField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: '${_getRoleDisplayName(role)} ID',
                      hintText: _getIdPlaceholder(role),
                      prefixIcon: Icon(_getRoleIcon(role)),
                      border: const OutlineInputBorder(),
                      // Error handling moved to SnackBar
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty && !isLoading) {
                        _performLogin(context, setState, school, role, value.trim());
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Enter your ${_getRoleDisplayName(role)} ID (UUID format)\nExample: a8076f03-3873-4ff5-beea-332fa4b20003',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  

                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _performLogin(
                          context, 
                          setState, 
                          school, 
                          role, 
                          idController.text.trim(),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getIdPlaceholder(role) {
    switch (role) {
      case 'student':
        return 'Enter your student UUID';
      case 'teacher':
        return 'Enter your teacher UUID';
      case 'admin':
        return 'Enter your authority UUID';
      default:
        return 'Enter your UUID';
    }
  }

  Future<void> _performLogin(
    BuildContext dialogContext,
    StateSetter setDialogState,
    Tenant school,
    String role,
    String userId,
  ) async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your ${_getRoleDisplayName(role)} ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Basic UUID validation
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (!uuidRegex.hasMatch(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UUID format'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setDialogState(() {
      // Loading state will be handled in the dialog
    });

    try {
      String apiEndpoint;
      switch (role) {
        case 'student':
          apiEndpoint = '/api/v1/school_authority/students/$userId';
          break;
        case 'teacher':
          apiEndpoint = '/api/v1/school_authority/teachers/$userId';
          break;
        case 'admin':
          apiEndpoint = '/api/v1/authorities/$userId';
          break;
        default:
          throw Exception('Invalid role');
      }

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}$apiEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        
        // Verify the user belongs to this school (tenant)
        if (role != 'admin') { // Admins might have access to multiple schools
          final userTenantId = userData['tenant_id']?.toString();
          if (userTenantId != null && userTenantId != school.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('This ${_getRoleDisplayName(role)} does not belong to ${school.schoolName}'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        
        // Login successful - close dialog and navigate
        Navigator.pop(dialogContext);
        _navigateToRole(role, school, userId, userData);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}!'),
            backgroundColor: Colors.green,
          ),
        );
        
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getRoleDisplayName(role)} not found with this ID'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.statusCode == 422) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid ID format'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('TimeoutException') 
              ? 'Connection timeout. Please check your internet connection.'
              : 'Login failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setDialogState(() {
        // Reset loading state
      });
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'student':
        return 'Student';
      case 'teacher':
        return 'Teacher';
      case 'admin':
        return 'School Authority';
      default:
        return 'User';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.person;
      case 'teacher':
        return Icons.person_2;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  void _navigateToRole(String role, Tenant school, String userId, Map<String, dynamic> userData) {
    // Navigate to respective dashboard with tenant ID and user ID
    switch (role) {
      case 'student':
        context.go('${AppConstants.studentDashboardRoute}?tenantId=${school.id}&userId=$userId');
        break;
      case 'teacher':
        context.go('${AppConstants.teacherDashboardRoute}?tenantId=${school.id}&userId=$userId');
        break;
      case 'admin':
        context.go('${AppConstants.adminDashboardRoute}?tenantId=${school.id}&userId=$userId');
        break;
    }
  }
}
