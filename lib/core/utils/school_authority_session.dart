// lib/core/utils/authority_session.dart
class AuthoritySession {
  static String? _authorityId;
  static String? _tenantId;
  static Map<String, dynamic>? _authorityData;

  static String? get authorityId => _authorityId;
  static String? get tenantId => _tenantId;
  static Map<String, dynamic>? get authorityData => _authorityData;

  static void setSession({
    required String authorityId,
    required String tenantId,
    Map<String, dynamic>? userData,
  }) {
    _authorityId = authorityId;
    _tenantId = tenantId;
    _authorityData = userData;
  }

  static void clearSession() {
    _authorityId = null;
    _tenantId = null;
    _authorityData = null;
  }

  static bool get hasValidSession => _authorityId != null && _tenantId != null;
}
