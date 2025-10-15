// lib/shared/widgets/navigation_sidebar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_theme.dart';

class NavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final String path;
  final String? badge;

  NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.path,
    this.badge,
  });
}

class NavigationSidebar extends StatelessWidget {
  final bool isOpen;
  final String userRole;
  final VoidCallback onClose;

  const NavigationSidebar({
    super.key,
    required this.isOpen,
    required this.userRole,
    required this.onClose,
  });

  List<NavigationItem> _getNavigationItems() {
    switch (userRole.toLowerCase()) {
      case 'student':
        return [
          NavigationItem(
            id: 'dashboard',
            label: AppStrings.dashboard,
            icon: Icons.dashboard,
            path: AppConstants.studentDashboardRoute,
          ),
          NavigationItem(
            id: 'assignments',
            label: AppStrings.assignments,
            icon: Icons.assignment,
            path: AppConstants.studentAssignmentsRoute,
            badge: '3',
          ),
          NavigationItem(
            id: 'grades',
            label: AppStrings.grades,
            icon: Icons.grade,
            path: AppConstants.studentGradesRoute,
          ),
          NavigationItem(
            id: 'attendance',
            label: AppStrings.attendance,
            icon: Icons.calendar_today,
            path: AppConstants.studentAttendanceRoute,
          ),
          NavigationItem(
            id: 'timetable',
            label: AppStrings.timetable,
            icon: Icons.schedule,
            path: AppConstants.studentTimetableRoute,
          ),
          NavigationItem(
            id: 'profile',
            label: AppStrings.profile,
            icon: Icons.person,
            path: AppConstants.studentProfileRoute,
          ),
        ];
      
      case 'teacher':
        return [
          NavigationItem(
            id: 'dashboard',
            label: AppStrings.dashboard,
            icon: Icons.dashboard,
            path: AppConstants.teacherDashboardRoute,
          ),
          NavigationItem(
            id: 'classes',
            label: AppStrings.classes,
            icon: Icons.class_,
            path: AppConstants.teacherClassesRoute,
          ),
          NavigationItem(
            id: 'students',
            label: AppStrings.students,
            icon: Icons.people,
            path: AppConstants.teacherStudentsRoute,
          ),
          NavigationItem(
            id: 'assignments',
            label: AppStrings.assignments,
            icon: Icons.assignment,
            path: AppConstants.teacherAssignmentsRoute,
          ),
          NavigationItem(
            id: 'attendance',
            label: AppStrings.attendance,
            icon: Icons.how_to_reg,
            path: AppConstants.teacherAttendanceRoute,
          ),
          NavigationItem(
            id: 'grades',
            label: AppStrings.grades,
            icon: Icons.grade,
            path: AppConstants.teacherGradesRoute,
          ),
          NavigationItem(
            id: 'reports',
            label: AppStrings.reports,
            icon: Icons.analytics,
            path: AppConstants.teacherReportsRoute,
          ),
          NavigationItem(
            id: 'profile',
            label: AppStrings.profile,
            icon: Icons.person,
            path: AppConstants.teacherProfileRoute,
          ),
        ];
      
      case 'admin':
        return [
          NavigationItem(
            id: 'dashboard',
            label: AppStrings.dashboard,
            icon: Icons.dashboard,
            path: AppConstants.adminDashboardRoute,
          ),
          NavigationItem(
            id: 'schools',
            label: AppStrings.schools,
            icon: Icons.school,
            path: AppConstants.adminSchoolsRoute,
          ),
          NavigationItem(
            id: 'teachers',
            label: AppStrings.teachers,
            icon: Icons.person_2,
            path: AppConstants.adminTeachersRoute,
          ),
          NavigationItem(
            id: 'students',
            label: AppStrings.students,
            icon: Icons.people,
            path: AppConstants.adminStudentsRoute,
          ),
          NavigationItem(
            id: 'analytics',
            label: AppStrings.analytics,
            icon: Icons.analytics,
            path: AppConstants.adminAnalyticsRoute,
          ),
          NavigationItem(
            id: 'reports',
            label: AppStrings.reports,
            icon: Icons.assessment,
            path: AppConstants.adminReportsRoute,
          ),
          NavigationItem(
            id: 'settings',
            label: AppStrings.settings,
            icon: Icons.settings,
            path: AppConstants.adminSettingsRoute,
          ),
          NavigationItem(
            id: 'profile',
            label: AppStrings.profile,
            icon: Icons.person,
            path: AppConstants.adminProfileRoute,
          ),
        ];
      
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getNavigationItems();
    final currentPath = GoRouterState.of(context).fullPath;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: isOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Mobile Close Button
            if (MediaQuery.of(context).size.width <= 768)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.lightGreen, AppTheme.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Navigation Menu',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            
            // User Info Section (Desktop only)
            if (MediaQuery.of(context).size.width > 768)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.lightGreen, AppTheme.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Text(
                        'JD', // This should come from user data
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'John Doe', // This should come from user data
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      userRole.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Delhi Public School',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Navigation Items
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isActive = currentPath == item.path;
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context.go(item.path);
                                // Don't close sidebar on navigation
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isActive ? AppTheme.primaryGreen : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      item.icon,
                                      color: isActive ? Colors.white : Colors.grey[600],
                                      size: 22,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: TextStyle(
                                          color: isActive ? Colors.white : Colors.grey[700],
                                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (item.badge != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isActive 
                                              ? Colors.white.withOpacity(0.3) 
                                              : Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item.badge!,
                                          style: TextStyle(
                                            color: isActive ? Colors.white : Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No navigation items',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No menu items available for your current role.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
