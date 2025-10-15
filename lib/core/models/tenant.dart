// lib/core/models/tenant.dart
class Tenant {
  final String id;
  final String schoolName;
  final String address;
  final String phone;
  final String email;
  final String principalName;
  final bool isActive;
  final double annualTuition;
  final double registrationFee;
  final int totalStudents;
  final int totalTeachers;
  final int totalStaff;
  final int maximumCapacity;
  final int currentEnrollment;
  final String schoolType;
  final List<String> gradeLevels;
  final DateTime? academicYearStart;
  final DateTime? academicYearEnd;
  final int? establishedYear;
  final String? accreditation;
  final String languageOfInstruction;
  final String? schoolCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Tenant({
    required this.id,
    required this.schoolName,
    required this.address,
    required this.phone,
    required this.email,
    required this.principalName,
    this.isActive = true,
    this.annualTuition = 0.0,
    this.registrationFee = 0.0,
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.totalStaff = 0,
    this.maximumCapacity = 0,
    this.currentEnrollment = 0,
    this.schoolType = 'K-12',
    this.gradeLevels = const [],
    this.academicYearStart,
    this.academicYearEnd,
    this.establishedYear,
    this.accreditation,
    this.languageOfInstruction = 'English',
    this.schoolCode,
    this.createdAt,
    this.updatedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id']?.toString() ?? '',
      schoolName: _parseToString(json['school_name']),
      address: _parseToString(json['address']),
      phone: _parseToString(json['phone']),
      email: _parseToString(json['email']),
      principalName: _parseToString(json['principal_name']),
      isActive: _parseToBool(json['is_active']),
      annualTuition: _parseToDouble(json['annual_tuition']),
      registrationFee: _parseToDouble(json['registration_fee']),
      totalStudents: _parseToInt(json['total_students']),
      totalTeachers: _parseToInt(json['total_teachers']),
      totalStaff: _parseToInt(json['total_staff']),
      maximumCapacity: _parseToInt(json['maximum_capacity']),
      currentEnrollment: _parseToInt(json['current_enrollment']),
      schoolType: json['school_type']?.toString() ?? 'K-12',
      gradeLevels: _parseToStringList(json['grade_levels']),
      academicYearStart: _parseToDateTime(json['academic_year_start']),
      academicYearEnd: _parseToDateTime(json['academic_year_end']),
      establishedYear: _parseToIntNullable(json['established_year']),
      accreditation: json['accreditation']?.toString(),
      languageOfInstruction: json['language_of_instruction']?.toString() ?? 'English',
      schoolCode: json['school_code']?.toString(),
      createdAt: _parseToDateTime(json['created_at']),
      updatedAt: _parseToDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_name': schoolName,
      'address': address,
      'phone': phone,
      'email': email,
      'principal_name': principalName,
      'is_active': isActive,
      'annual_tuition': annualTuition,
      'registration_fee': registrationFee,
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'total_staff': totalStaff,
      'maximum_capacity': maximumCapacity,
      'current_enrollment': currentEnrollment,
      'school_type': schoolType,
      'grade_levels': gradeLevels,
      'academic_year_start': academicYearStart?.toIso8601String(),
      'academic_year_end': academicYearEnd?.toIso8601String(),
      'established_year': establishedYear,
      'accreditation': accreditation,
      'language_of_instruction': languageOfInstruction,
      'school_code': schoolCode,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods for safe parsing
  static String _parseToString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static bool _parseToBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return true;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  static int? _parseToIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static DateTime? _parseToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static List<String> _parseToStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Utility getters
  double get capacityUtilization {
    if (maximumCapacity == 0) return 0.0;
    return (currentEnrollment / maximumCapacity * 100);
  }

  double get studentTeacherRatio {
    if (totalTeachers == 0) return 0.0;
    return totalStudents / totalTeachers;
  }

  bool get isOverCapacity => currentEnrollment > maximumCapacity;

  String get statusText => isActive ? 'Active' : 'Inactive';

  // Copy with method for updates
  Tenant copyWith({
    String? id,
    String? schoolName,
    String? address,
    String? phone,
    String? email,
    String? principalName,
    bool? isActive,
    double? annualTuition,
    double? registrationFee,
    int? totalStudents,
    int? totalTeachers,
    int? totalStaff,
    int? maximumCapacity,
    int? currentEnrollment,
    String? schoolType,
    List<String>? gradeLevels,
    DateTime? academicYearStart,
    DateTime? academicYearEnd,
    int? establishedYear,
    String? accreditation,
    String? languageOfInstruction,
    String? schoolCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      schoolName: schoolName ?? this.schoolName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      principalName: principalName ?? this.principalName,
      isActive: isActive ?? this.isActive,
      annualTuition: annualTuition ?? this.annualTuition,
      registrationFee: registrationFee ?? this.registrationFee,
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      totalStaff: totalStaff ?? this.totalStaff,
      maximumCapacity: maximumCapacity ?? this.maximumCapacity,
      currentEnrollment: currentEnrollment ?? this.currentEnrollment,
      schoolType: schoolType ?? this.schoolType,
      gradeLevels: gradeLevels ?? this.gradeLevels,
      academicYearStart: academicYearStart ?? this.academicYearStart,
      academicYearEnd: academicYearEnd ?? this.academicYearEnd,
      establishedYear: establishedYear ?? this.establishedYear,
      accreditation: accreditation ?? this.accreditation,
      languageOfInstruction: languageOfInstruction ?? this.languageOfInstruction,
      schoolCode: schoolCode ?? this.schoolCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
