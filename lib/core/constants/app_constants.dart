// lib/core/constants/app_constants.dart
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://192.168.1.2:8000';
  static const String apiVersion = '/api/v1';

  // Public Routes
  static const String homeRoute = '/';
  static const String schoolSelectionRoute = '/school-selection';
  static const String addSchoolRoute = '/add-school';
  static const String loginRoute = '/login';
  static const String createSchoolRoute = '/create-school';
  static const String tenantManagementRoute = '/tenant-management';
  static const String schoolManagementRoute = '/school-management';

  // Global/System Admin Routes
  static const String globalAnalyticsRoute = '/global/analytics';
  static const String systemSettingsRoute = '/global/settings';

  // Student Routes
  static const String studentDashboardRoute = '/student/dashboard';
  static const String studentAssignmentsRoute = '/student/assignments';
  static const String studentGradesRoute = '/student/grades';
  static const String studentAttendanceRoute = '/student/attendance';
  static const String studentTimetableRoute = '/student/timetable';
  static const String studentProfileRoute = '/student/profile';
  
  // Teacher Routes
  static const String teacherDashboardRoute = '/teacher/dashboard';
  static const String teacherClassesRoute = '/teacher/classes';
  static const String teacherStudentsRoute = '/teacher/students';
  static const String teacherAssignmentsRoute = '/teacher/assignments';
  static const String teacherAttendanceRoute = '/teacher/attendance';
  static const String teacherGradesRoute = '/teacher/grades';
  static const String teacherReportsRoute = '/teacher/reports';
  static const String teacherProfileRoute = '/teacher/profile';
  
  // Admin Routes (School-level)
  static const String adminDashboardRoute = '/admin/dashboard';
  static const String adminSchoolsRoute = '/admin/schools';
  static const String adminTeachersRoute = '/admin/teachers';
  static const String adminStudentsRoute = '/admin/students';
  static const String adminAnalyticsRoute = '/admin/analytics';
  static const String adminReportsRoute = '/admin/reports';
  static const String adminSettingsRoute = '/admin/settings';
  static const String adminProfileRoute = '/admin/profile';
  static const String adminTenantManagementRoute = '/admin/tenant-management';
}
