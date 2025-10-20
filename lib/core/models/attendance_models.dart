// lib/features/admin/models/attendance_models.dart
import 'package:flutter/foundation.dart';

enum AttendanceStatus { present, absent, late, excused, sick, partial, earlydeparture, suspended }
enum AttendanceType { daily, period, event, exam, assembly, extracurricular }
enum UserType { student, teacher, school_authority, staff }
enum AttendanceMode { manual, biometric, qrcode, mobileapp, rfid }

AttendanceStatus statusFrom(String s) =>
  AttendanceStatus.values.firstWhere((e) => describeEnum(e) == s);
String statusTo(AttendanceStatus s) => describeEnum(s);

AttendanceType typeFrom(String s) =>
  AttendanceType.values.firstWhere((e) => describeEnum(e) == s);
String typeTo(AttendanceType t) => describeEnum(t);

UserType userTypeFrom(String s) =>
  UserType.values.firstWhere((e) => describeEnum(e) == s);
String userTypeTo(UserType t) => describeEnum(t);

AttendanceMode modeFrom(String s) =>
  AttendanceMode.values.firstWhere((e) => describeEnum(e) == s);
String modeTo(AttendanceMode t) => describeEnum(t);

class AttendanceRecord {
  final String id;
  final String tenantId;
  final String userId;
  final UserType userType;
  final String? classId;
  final String markedBy;
  final UserType markedByType;
  final DateTime attendanceDate;
  final DateTime attendanceTime;
  final AttendanceType attendanceType;
  final AttendanceMode attendanceMode;
  final AttendanceStatus status;
  final String? checkInTime; // keep as "HH:mm:ss" to match API
  final String? checkOutTime;
  final int? periodNumber;
  final String? subjectName;
  final String? location;
  final String? remarks;
  final String? reasonForAbsence;
  final bool? isExcused;
  final String? approvedBy;
  final String? approvalDate;
  final String? approvalRemarks;
  final String? academicYear;
  final String? term;
  final String? latitude;
  final String? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceRecord({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.userType,
    required this.classId,
    required this.markedBy,
    required this.markedByType,
    required this.attendanceDate,
    required this.attendanceTime,
    required this.attendanceType,
    required this.attendanceMode,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.periodNumber,
    this.subjectName,
    this.location,
    this.remarks,
    this.reasonForAbsence,
    this.isExcused,
    this.approvedBy,
    this.approvalDate,
    this.approvalRemarks,
    this.academicYear,
    this.term,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
    id: j['id'],
    tenantId: j['tenant_id'] ?? j['tenantId'] ?? '',
    userId: j['userid'] ?? j['user_id'],
    userType: userTypeFrom(j['user_type'] ?? j['usertype']),
    classId: j['classid'] ?? j['class_id'],
    markedBy: j['markedby'] ?? j['marked_by'],
    markedByType: userTypeFrom(j['markedbytype'] ?? j['marked_by_type']),
    attendanceDate: DateTime.parse(j['attendance_date'] ?? j['attendancedate']),
    attendanceTime: DateTime.parse(j['attendance_time'] ?? j['attendancetime']),
    attendanceType: typeFrom(j['attendance_type'] ?? j['attendancetype']),
    attendanceMode: modeFrom((j['attendance_mode'] ?? j['attendancemode'] ?? 'manual')),
    status: statusFrom(j['status']),
    checkInTime: j['check_in_time'] ?? j['checkintime'],
    checkOutTime: j['check_out_time'] ?? j['checkouttime'],
    periodNumber: j['period_number'] ?? j['periodnumber'],
    subjectName: j['subject_name'] ?? j['subjectname'],
    location: j['location'],
    remarks: j['remarks'],
    reasonForAbsence: j['reason_for_absence'] ?? j['reasonforabsence'],
    isExcused: j['is_excused'] ?? j['isexcused'],
    approvedBy: j['approved_by'] ?? j['approvedby'],
    approvalDate: j['approval_date'] ?? j['approvaldate'],
    approvalRemarks: j['approval_remarks'] ?? j['approvalremarks'],
    academicYear: j['academic_year'] ?? j['academicyear'],
    term: j['term'],
    latitude: j['latitude'],
    longitude: j['longitude'],
    createdAt: DateTime.parse(j['created_at'] ?? j['createdat']),
    updatedAt: DateTime.parse(j['updated_at'] ?? j['updatedat']),
  );

  Map<String, dynamic> toMarkBody() => {
    'user_id': userId,
    'user_type': userTypeTo(userType),
    'class_id': classId,
    'attendance_date': attendanceDate.toIso8601String().split('T').first,
    'attendance_type': typeTo(attendanceType),
    'status': statusTo(status),
    'check_in_time': checkInTime,
    'check_out_time': checkOutTime,
    'period_number': periodNumber,
    'subject_name': subjectName,
    'location': location,
    'remarks': remarks,
    'reason_for_absence': reasonForAbsence,
    'academic_year': academicYear,
    'term': term,
  }..removeWhere((k, v) => v == null);
}
