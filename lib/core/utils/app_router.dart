// lib/core/utils/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/screens/landing_screen.dart';
import '../../features/screens/school_selection_screen.dart';
import '../../shared/widgets/main_layout.dart';

import '../../features/tenant_management/screens/tenant_management_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/student_assignments_screen.dart';

import '../../features/teacher/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/screens/teacher_classes_screen.dart';

import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/send_notification_screen.dart';
import '../../features/admin/screens/class_screen.dart';
import '../../features/admin/screens/student_management_screen.dart';
import '../../features/admin/screens/timetable_screen.dart';
import '../../features/admin/screens/attendance_screen.dart';
import '../../services/attendance_service.dart';

import '../constants/app_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.homeRoute,
  routes: [
    // Public routes
    GoRoute(
      path: AppConstants.homeRoute,
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: AppConstants.schoolSelectionRoute,
      builder: (context, state) => const SchoolSelectionScreen(),
    ),

    // Global admin/tenant management
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        userRole: state.uri.queryParameters['role'] ?? 'tenant_manager',
        tenantId: null,
        userId: state.uri.queryParameters['userId'],
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppConstants.tenantManagementRoute,
          builder: (context, state) => const TenantManagementScreen(),
        ),
      ],
    ),

    // Student
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        userRole: 'student',
        tenantId: state.uri.queryParameters['tenantId'],
        userId: state.uri.queryParameters['userId'],
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppConstants.studentDashboardRoute,
          builder: (context, state) => const StudentDashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.studentNotificationsRoute,
          builder: (context, state) => NotificationsScreen(
            userId: state.uri.queryParameters['userId'] ?? '',
            userType: 'student',
            tenantId: state.uri.queryParameters['tenantId'] ?? '',
          ),
        ),
        GoRoute(
          path: AppConstants.studentAssignmentsRoute,
          builder: (context, state) => const StudentAssignmentsScreen(),
        ),
      ],
    ),

    // Teacher
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        userRole: 'teacher',
        tenantId: state.uri.queryParameters['tenantId'],
        userId: state.uri.queryParameters['userId'],
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppConstants.teacherDashboardRoute,
          builder: (context, state) => const TeacherDashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.teacherNotificationsRoute,
          builder: (context, state) => NotificationsScreen(
            userId: state.uri.queryParameters['userId'] ?? '',
            userType: 'teacher',
            tenantId: state.uri.queryParameters['tenantId'] ?? '',
          ),
        ),
        GoRoute(
          path: AppConstants.teacherSendNotificationRoute,
          builder: (context, state) => SendNotificationScreen(
            senderId: state.uri.queryParameters['userId'] ?? '',
            senderType: 'teacher',
            tenantId: state.uri.queryParameters['tenantId'] ?? '',
          ),
        ),
        GoRoute(
          path: AppConstants.teacherClassesRoute,
          builder: (context, state) => const TeacherClassesScreen(),
        ),
      ],
    ),

    // School Authority (Admin)
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        userRole: 'school_authority',
        tenantId: state.uri.queryParameters['tenantId'],
        userId: state.uri.queryParameters['userId'],
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppConstants.adminDashboardRoute,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.adminNotificationsRoute,
          builder: (context, state) => NotificationsScreen(
            userId: state.uri.queryParameters['userId'] ?? '',
            userType: 'school_authority',
            tenantId: state.uri.queryParameters['tenantId'] ?? '',
          ),
        ),
        GoRoute(
          path: AppConstants.adminSendNotificationRoute,
          builder: (context, state) => SendNotificationScreen(
            senderId: state.uri.queryParameters['userId'] ?? '',
            senderType: 'school_authority',
            tenantId: state.uri.queryParameters['tenantId'] ?? '',
          ),
        ),

        GoRoute(
          path: AppConstants.adminAttendanceRoute,
          builder: (context, state) => AttendanceScreen(
            service: AttendanceService(AppConstants.apiBaseUrl),
            tenantId: state.uri.queryParameters['tenantId'] ?? '',
            authorityUserId: state.uri.queryParameters['userId'] ?? '',
          ),
        ),

        // Student management
        GoRoute(
          path: '/school_authority/students',
          builder: (context, state) => const StudentManagementScreen(),
        ),

        // Classes management (this is the ClassScreen you asked to wire)
        GoRoute(
          path: '/school_authority/classes',
          builder: (context, state) => ClassScreen(
            baseUrl: AppConstants.apiBaseUrl,
            tenantId: state.uri.queryParameters['tenantId'] ?? '',
            headers: {
              // Example: inject auth header if present in app state
              // 'Authorization': 'Bearer ${someToken}',
            },
          ),
        ),
        GoRoute(
          path: '/school_authority/timetable',
          builder: (context, state) => TimetableScreen(
            baseUrl: AppConstants.apiBaseUrl,
            tenantId: state.uri.queryParameters['tenantId'] ?? '',
            currentUserId: state.uri.queryParameters['userId'] ?? '',
            academicYear:
                state.uri.queryParameters['academicYear'] ?? '2025-26',
          ),
        ),

        // Placeholder example
        GoRoute(
          path: AppConstants.adminNotificationAnalyticsRoute,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Notification Analytics'),
        ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
