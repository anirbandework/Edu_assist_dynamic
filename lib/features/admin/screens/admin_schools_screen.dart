// lib/features/admin/screens/admin_schools_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

class AdminSchoolsScreen extends StatefulWidget {
  const AdminSchoolsScreen({super.key});

  @override
  State<AdminSchoolsScreen> createState() => _AdminSchoolsScreenState();
}

class _AdminSchoolsScreenState extends State<AdminSchoolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _schools = [
    {
      'id': '1',
      'name': 'Delhi Public School',
      'address': '123 Education Street, New Delhi',
      'students': 1247,
      'teachers': 68,
      'status': 'Active',
      'principal': 'Dr. Rajesh Kumar',
      'phone': '+91 98765 43210',
      'email': 'principal@dpsdelhi.edu.in',
      'established': '1995',
    },
    {
      'id': '2',
      'name': 'Modern School',
      'address': '456 Learning Avenue, Mumbai',
      'students': 892,
      'teachers': 45,
      'status': 'Active',
      'principal': 'Mrs. Priya Sharma',
      'phone': '+91 98765 43211',
      'email': 'admin@modernschool.edu.in',
      'established': '1998',
    },
    {
      'id': '3',
      'name': 'St. Mary\'s Convent',
      'address': '789 Knowledge Park, Bangalore',
      'students': 654,
      'teachers': 32,
      'status': 'Active',
      'principal': 'Sister Margaret',
      'phone': '+91 98765 43212',
      'email': 'principal@stmarys.edu.in',
      'established': '1985',
    },
    {
      'id': '4',
      'name': 'Kendriya Vidyalaya',
      'address': '321 Government Complex, Chennai',
      'students': 1156,
      'teachers': 56,
      'status': 'Active',
      'principal': 'Mr. Suresh Nair',
      'phone': '+91 98765 43213',
      'email': 'kv.chennai@kvs.gov.in',
      'established': '1992',
    },
    {
      'id': '5',
      'name': 'International Academy',
      'address': '654 Global Campus, Pune',
      'students': 423,
      'teachers': 28,
      'status': 'Inactive',
      'principal': 'Dr. Amanda Wilson',
      'phone': '+91 98765 43214',
      'email': 'admin@intlacademy.edu.in',
      'established': '2005',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchools = _schools.where((school) {
      final matchesSearch = school['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
                          school['address'].toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' || school['status'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'School Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage all registered schools in the system',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add School'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Search and Filter Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search schools...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _selectedFilter,
              items: ['All', 'Active', 'Inactive'].map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Schools List
        Expanded(
          child: ListView.builder(
            itemCount: filteredSchools.length,
            itemBuilder: (context, index) {
              final school = filteredSchools[index];
              return _buildSchoolCard(school);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolCard(Map<String, dynamic> school) {
    final bool isActive = school['status'] == 'Active';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.indigo[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.school,
                    color: isActive ? Colors.indigo[600] : Colors.grey[600],
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
                              school['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              school['status'],
                              style: TextStyle(
                                color: isActive ? Colors.green[700] : Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        school['address'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Established: ${school['established']}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit School'),
                    ),
                    PopupMenuItem(
                      value: isActive ? 'deactivate' : 'activate',
                      child: Text(isActive ? 'Deactivate' : 'Activate'),
                    ),
                    const PopupMenuItem(
                      value: 'reports',
                      child: Text('View Reports'),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.people,
                    '${school['students']}',
                    'Students',
                    Colors.blue,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildStatItem(
                    Icons.person_2,
                    '${school['teachers']}',
                    'Teachers',
                    Colors.green,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildStatItem(
                    Icons.percent,
                    '${((school['students'] as int) / (school['teachers'] as int)).toStringAsFixed(1)}',
                    'Student/Teacher',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Contact Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                school['principal'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                school['phone'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          school['email'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo[600],
                      side: BorderSide(color: Colors.indigo[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('Analytics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Manage'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
