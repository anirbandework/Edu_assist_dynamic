// lib/core/utils/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/screens/landing_screen.dart';
import '../../features/screens/school_selection_screen.dart';
import '../../shared/widgets/main_layout.dart';

import '../../features/tenant_management/screens/tenant_management_screen.dart'; 

import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/student_assignments_screen.dart';
// import '../../features/student/screens/student_grades_screen.dart';
// import '../../features/student/screens/student_attendance_screen.dart';
// import '../../features/student/screens/student_timetable_screen.dart';
// import '../../features/student/screens/student_profile_screen.dart';
import '../../features/teacher/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/screens/teacher_classes_screen.dart';
// import '../../features/teacher/screens/teacher_students_screen.dart';
// import '../../features/teacher/screens/teacher_assignments_screen.dart';
// import '../../features/teacher/screens/teacher_attendance_screen.dart';
// import '../../features/teacher/screens/teacher_grades_screen.dart';
// import '../../features/teacher/screens/teacher_reports_screen.dart';
// import '../../features/teacher/screens/teacher_profile_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_schools_screen.dart';
// import '../../features/admin/screens/admin_teachers_screen.dart';
// import '../../features/admin/screens/admin_students_screen.dart';
// import '../../features/admin/screens/admin_analytics_screen.dart';
// import '../../features/admin/screens/admin_reports_screen.dart';
// import '../../features/admin/screens/admin_settings_screen.dart';
// import '../../features/admin/screens/admin_profile_screen.dart';
import '../constants/app_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.homeRoute,
  routes: [
    // Public Routes (No Layout)
    GoRoute(
      path: AppConstants.homeRoute,
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: AppConstants.schoolSelectionRoute,
      builder: (context, state) => const SchoolSelectionScreen(),
    ),
    
    // Global Admin/Tenant Management Shell Route with Layout
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        userRole: state.uri.queryParameters['role'] ?? 'tenant_manager',
        tenantId: null, // Global users don't have a specific tenant
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppConstants.tenantManagementRoute,
          builder: (context, state) => const TenantManagementScreen(),
        ),
        // Add future global routes here
        // GoRoute(
        //   path: AppConstants.globalAnalyticsRoute,
        //   builder: (context, state) => const GlobalAnalyticsScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.systemSettingsRoute,
        //   builder: (context, state) => const SystemSettingsScreen(),
        // ),
      ],
    ),
    
    // Student Shell Route with Layout
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        userRole: 'student',
        tenantId: state.uri.queryParameters['tenantId'],
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppConstants.studentDashboardRoute,
          builder: (context, state) => const StudentDashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.studentAssignmentsRoute,
          builder: (context, state) => const StudentAssignmentsScreen(),
        ),
        // GoRoute(
        //   path: AppConstants.studentGradesRoute,
        //   builder: (context, state) => const StudentGradesScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.studentAttendanceRoute,
        //   builder: (context, state) => const StudentAttendanceScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.studentTimetableRoute,
        //   builder: (context, state) => const StudentTimetableScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.studentProfileRoute,
        //   builder: (context, state) => const StudentProfileScreen(),
        // ),
      ],
    ),
    
    // Teacher Shell Route with Layout
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        userRole: 'teacher',
        tenantId: state.uri.queryParameters['tenantId'],
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppConstants.teacherDashboardRoute,
          builder: (context, state) => const TeacherDashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.teacherClassesRoute,
          builder: (context, state) => const TeacherClassesScreen(),
        ),
        // GoRoute(
        //   path: AppConstants.teacherStudentsRoute,
        //   builder: (context, state) => const TeacherStudentsScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.teacherAssignmentsRoute,
        //   builder: (context, state) => const TeacherAssignmentsScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.teacherAttendanceRoute,
        //   builder: (context, state) => const TeacherAttendanceScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.teacherGradesRoute,
        //   builder: (context, state) => const TeacherGradesScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.teacherReportsRoute,
        //   builder: (context, state) => const TeacherReportsScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.teacherProfileRoute,
        //   builder: (context, state) => const TeacherProfileScreen(),
        // ),
      ],
    ),
    
    // Admin Shell Route with Layout
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        userRole: 'admin',
        tenantId: state.uri.queryParameters['tenantId'],
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppConstants.adminDashboardRoute,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.adminSchoolsRoute,
          builder: (context, state) => const AdminSchoolsScreen(),
        ),
        // GoRoute(
        //   path: AppConstants.adminTeachersRoute,
        //   builder: (context, state) => const AdminTeachersScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.adminStudentsRoute,
        //   builder: (context, state) => const AdminStudentsScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.adminAnalyticsRoute,
        //   builder: (context, state) => const AdminAnalyticsScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.adminReportsRoute,
        //   builder: (context, state) => const AdminReportsScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.adminSettingsRoute,
        //   builder: (context, state) => const AdminSettingsScreen(),
        // ),
        // GoRoute(
        //   path: AppConstants.adminProfileRoute,
        //   builder: (context, state) => const AdminProfileScreen(),
        // ),
      ],
    ),
  ],
);

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange[600]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is under construction',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
