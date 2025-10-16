// lib/core/utils/student_session.dart
class StudentSession {
  static String? _studentId;
  static String? _tenantId;
  static Map<String, dynamic>? _studentData;

  static String? get studentId => _studentId;
  static String? get tenantId => _tenantId;
  static Map<String, dynamic>? get studentData => _studentData;

  static void setSession({
    required String studentId,
    required String tenantId,
    Map<String, dynamic>? userData,
  }) {
    _studentId = studentId;
    _tenantId = tenantId;
    _studentData = userData;
  }

  static void clearSession() {
    _studentId = null;
    _tenantId = null;
    _studentData = null;
  }

  static bool get hasValidSession => _studentId != null && _tenantId != null;
}
