import 'dart:convert';

class ClassModel {
  final String id;
  final String tenantId;
  final String className;
  final int gradeLevel;
  final String section;
  final String academicYear;
  final int maximumStudents;
  final int currentStudents;
  final String? classroom;
  final bool isActive;
  final int? availableSpots;
  final double? occupancyRate;
  final String? createdBy;
  final String? createdAt;
  final String? lastModifiedBy;
  final String? lastModifiedAt;
  final List<Map<String, dynamic>>? timeSlots;
  final Map<String, List<Map<String, dynamic>>>? weeklySchedule;

  const ClassModel({
    required this.id,
    required this.tenantId,
    required this.className,
    required this.gradeLevel,
    required this.section,
    required this.academicYear,
    required this.maximumStudents,
    required this.currentStudents,
    required this.isActive,
    this.classroom,
    this.availableSpots,
    this.occupancyRate,
    this.createdBy,
    this.createdAt,
    this.lastModifiedBy,
    this.lastModifiedAt,
    this.timeSlots,
    this.weeklySchedule,
  });

  factory ClassModel.fromJson(Map<String, dynamic> j) => ClassModel(
        id: j['id']?.toString() ?? '',
        tenantId: j['tenant_id']?.toString() ?? '',
        className: j['class_name'] ?? '',
        gradeLevel: (j['grade_level'] ?? 0) is int
            ? j['grade_level']
            : int.tryParse(j['grade_level'].toString()) ?? 0,
        section: j['section'] ?? '',
        academicYear: j['academic_year'] ?? '',
        maximumStudents: (j['maximum_students'] ?? 0) is int
            ? j['maximum_students']
            : int.tryParse(j['maximum_students'].toString()) ?? 0,
        currentStudents: (j['current_students'] ?? 0) is int
            ? j['current_students']
            : int.tryParse(j['current_students'].toString()) ?? 0,
        classroom: (j['classroom']?.toString().isEmpty ?? true)
            ? null
            : j['classroom'].toString(),
        isActive: j['is_active'] ?? true,
        availableSpots: j['available_spots'],
        occupancyRate: j['occupancy_rate'] == null
            ? null
            : (j['occupancy_rate'] is num
                ? (j['occupancy_rate'] as num).toDouble()
                : double.tryParse(j['occupancy_rate'].toString())),
        createdBy: j['created_by'],
        createdAt: j['created_at'],
        lastModifiedBy: j['last_modified_by'],
        lastModifiedAt: j['last_modified_at'],
        timeSlots: j['time_slots'] != null ? List<Map<String, dynamic>>.from(j['time_slots']) : null,
        weeklySchedule: j['weekly_schedule'] != null ? Map<String, List<Map<String, dynamic>>>.from(
          (j['weekly_schedule'] as Map).map((k, v) => MapEntry(k.toString(), List<Map<String, dynamic>>.from(v)))
        ) : null,
      );

  Map<String, dynamic> toCreateJson() => {
        'tenant_id': tenantId,
        'class_name': className,
        'grade_level': gradeLevel,
        'section': section,
        'academic_year': academicYear,
        'maximum_students': maximumStudents,
        'current_students': currentStudents,
        'classroom': (classroom?.isEmpty ?? true) ? null : classroom,
        'is_active': isActive,
        'created_by': createdBy,
        'created_at': createdAt,
        'last_modified_by': lastModifiedBy,
        'last_modified_at': lastModifiedAt,
        'time_slots': timeSlots,
        'weekly_schedule': weeklySchedule,
      };

  Map<String, dynamic> toUpdateJson() => {
        'class_name': className,
        'grade_level': gradeLevel,
        'section': section,
        'academic_year': academicYear,
        'maximum_students': maximumStudents,
        'current_students': currentStudents,
        'classroom': (classroom?.isEmpty ?? true) ? null : classroom,
        'is_active': isActive,
      };

  static List<ClassModel> listFromPaginated(dynamic body) {
    if (body is Map && body['items'] is List) {
      return (body['items'] as List)
          .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (body is List) {
      return body
          .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  ClassModel copyWith({
    String? className,
    int? gradeLevel,
    String? section,
    String? academicYear,
    int? maximumStudents,
    int? currentStudents,
    String? classroom,
    bool? isActive,
    String? createdBy,
    String? createdAt,
    String? lastModifiedBy,
    String? lastModifiedAt,
    List<Map<String, dynamic>>? timeSlots,
    Map<String, List<Map<String, dynamic>>>? weeklySchedule,
  }) {
    return ClassModel(
      id: id,
      tenantId: tenantId,
      className: className ?? this.className,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      section: section ?? this.section,
      academicYear: academicYear ?? this.academicYear,
      maximumStudents: maximumStudents ?? this.maximumStudents,
      currentStudents: currentStudents ?? this.currentStudents,
      classroom: classroom ?? this.classroom,
      isActive: isActive ?? this.isActive,
      availableSpots: availableSpots,
      occupancyRate: occupancyRate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      timeSlots: timeSlots ?? this.timeSlots,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
    );
  }

  @override
  String toString() => jsonEncode({
        'id': id,
        'tenant_id': tenantId,
        'class_name': className,
        'grade_level': gradeLevel,
        'section': section,
        'academic_year': academicYear,
        'maximum_students': maximumStudents,
        'current_students': currentStudents,
        'classroom': classroom,
        'is_active': isActive,
      });
}
