// lib/core/utils/teacher_session.dart
class TeacherSession {
  static String? _teacherId;
  static String? _tenantId;
  static Map<String, dynamic>? _teacherData;

  static String? get teacherId => _teacherId;
  static String? get tenantId => _tenantId;
  static Map<String, dynamic>? get teacherData => _teacherData;

  static void setSession({
    required String teacherId,
    required String tenantId,
    Map<String, dynamic>? userData,
  }) {
    _teacherId = teacherId;
    _tenantId = tenantId;
    _teacherData = userData;
  }

  static void clearSession() {
    _teacherId = null;
    _tenantId = null;
    _teacherData = null;
  }

  static bool get hasValidSession => _teacherId != null && _tenantId != null;
}
