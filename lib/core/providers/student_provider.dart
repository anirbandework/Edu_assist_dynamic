// lib/core/providers/student_provider.dart
import 'package:flutter/foundation.dart';

class StudentProvider extends ChangeNotifier {
  String? _studentId;
  String? _tenantId;
  Map<String, dynamic>? _studentData;
  
  String? get studentId => _studentId;
  String? get tenantId => _tenantId;
  Map<String, dynamic>? get studentData => _studentData;
  
  void setStudentData({
    required String studentId,
    required String tenantId,
    Map<String, dynamic>? userData,
  }) {
    _studentId = studentId;
    _tenantId = tenantId;
    _studentData = userData;
    notifyListeners();
  }
  
  void clearStudentData() {
    _studentId = null;
    _tenantId = null;
    _studentData = null;
    notifyListeners();
  }
  
  bool get hasValidSession => _studentId != null && _tenantId != null;
}
