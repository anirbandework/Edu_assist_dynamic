// lib/features/teacher/screens/teacher_classes_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _classes = [
    {
      'id': '1',
      'name': 'Mathematics - Grade 10A',
      'students': 28,
      'room': 'Room 201',
      'time': 'Mon, Wed, Fri • 09:00 - 10:30',
      'color': Colors.blue,
      'status': 'Active',
      'assignments': 5,
      'pendingGrades': 3,
    },
    {
      'id': '2',
      'name': 'Advanced Calculus - Grade 12',
      'students': 24,
      'room': 'Room 205',
      'time': 'Tue, Thu • 11:00 - 12:30',
      'color': Colors.green,
      'status': 'Active',
      'assignments': 3,
      'pendingGrades': 8,
    },
    {
      'id': '3',
      'name': 'Mathematics - Grade 10B',
      'students': 30,
      'room': 'Room 201',
      'time': 'Mon, Wed, Fri • 14:00 - 15:30',
      'color': Colors.orange,
      'status': 'Active',
      'assignments': 4,
      'pendingGrades': 12,
    },
    {
      'id': '4',
      'name': 'Geometry - Grade 9',
      'students': 26,
      'room': 'Room 103',
      'time': 'Tue, Thu • 13:00 - 14:30',
      'color': Colors.purple,
      'status': 'Active',
      'assignments': 2,
      'pendingGrades': 0,
    },
    {
      'id': '5',
      'name': 'Statistics - Grade 11',
      'students': 22,
      'room': 'Room 204',
      'time': 'Mon, Wed • 15:30 - 17:00',
      'color': Colors.red,
      'status': 'Completed',
      'assignments': 6,
      'pendingGrades': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredClasses = _classes.where((classItem) {
      if (_selectedFilter == 'All') return true;
      return classItem['status'] == _selectedFilter;
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
                    'My Classes',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage all your classes and track student progress',
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
              label: const Text('New Class'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Filter Chips
        Row(
          children: [
            Text(
              'Filter:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Active', 'Completed'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.indigo[600],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Classes Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 768 ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: MediaQuery.of(context).size.width > 768 ? 1.4 : 1.2,
            ),
            itemCount: filteredClasses.length,
            itemBuilder: (context, index) {
              final classItem = filteredClasses[index];
              return _buildClassCard(classItem);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classItem) {
    final Color color = classItem['color'] as Color;
    final bool isCompleted = classItem['status'] == 'Completed';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.class_,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.grey[300] : color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            classItem['status'],
                            style: TextStyle(
                              color: isCompleted ? Colors.grey[700] : color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
                        child: Text('Edit Class'),
                      ),
                      const PopupMenuItem(
                        value: 'attendance',
                        child: Text('Take Attendance'),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Class Info
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${classItem['students']} students',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.room, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    classItem['room'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      classItem['time'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Action Stats
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '${classItem['assignments']}',
                      'Assignments',
                      Icons.assignment,
                      Colors.blue,
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    _buildStatItem(
                      '${classItem['pendingGrades']}',
                      'Pending',
                      Icons.grade,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Manage'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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
}
