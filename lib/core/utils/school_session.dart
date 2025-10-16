// lib/core/utils/school_session.dart
class SchoolSession {
  static String? _schoolName;
  static String? _schoolId;
  static String? _schoolCode;
  static String? _tenantId;

  static String? get schoolName => _schoolName;
  static String? get schoolId => _schoolId;
  static String? get schoolCode => _schoolCode;
  static String? get tenantId => _tenantId;

  static void setSchoolData({
    required String schoolName,
    required String schoolId,
    String? schoolCode,
    String? tenantId,
  }) {
    _schoolName = schoolName;
    _schoolId = schoolId;
    _schoolCode = schoolCode;
    _tenantId = tenantId;
  }

  static void clearSchoolData() {
    _schoolName = null;
    _schoolId = null;
    _schoolCode = null;
    _tenantId = null;
  }

  static bool get hasSchoolData => _schoolName != null && _schoolId != null;
}
