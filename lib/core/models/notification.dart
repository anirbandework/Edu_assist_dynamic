// lib/core/models/notification.dart
class AppNotification {
  final String id;
  final String tenantId;
  final String senderId;
  final String senderType;
  final String title;
  final String message;
  final String? shortMessage;
  final NotificationType notificationType;
  final NotificationPriority priority;
  final RecipientType recipientType;
  final Map<String, dynamic>? recipientConfig;
  final List<DeliveryChannel> deliveryChannels;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? attachments;
  final String? actionUrl;
  final String? actionText;
  final String? category;
  final List<String>? tags;
  final String? academicYear;
  final String? term;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NotificationStatus status;
  final bool isRead;
  final DateTime? readAt;

  AppNotification({
    required this.id,
    required this.tenantId,
    required this.senderId,
    required this.senderType,
    required this.title,
    required this.message,
    this.shortMessage,
    required this.notificationType,
    required this.priority,
    required this.recipientType,
    this.recipientConfig,
    required this.deliveryChannels,
    this.scheduledAt,
    this.expiresAt,
    this.attachments,
    this.actionUrl,
    this.actionText,
    this.category,
    this.tags,
    this.academicYear,
    this.term,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.isRead = false,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      tenantId: json['tenant_id'],
      senderId: json['sender_id'],
      senderType: json['sender_type'] ?? 'school_authority',
      title: json['title'],
      message: json['message'],
      shortMessage: json['short_message'],
      notificationType: NotificationType.fromString(json['notification_type']),
      priority: NotificationPriority.fromString(json['priority']),
      recipientType: RecipientType.fromString(json['recipient_type']),
      recipientConfig: json['recipient_config'],
      deliveryChannels: (json['delivery_channels'] as List?)
          ?.map((e) => DeliveryChannel.fromString(e))
          .toList() ?? [],
      scheduledAt: json['scheduled_at'] != null 
          ? DateTime.parse(json['scheduled_at']) 
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      attachments: json['attachments'],
      actionUrl: json['action_url'],
      actionText: json['action_text'],
      category: json['category'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : null,
      academicYear: json['academic_year'],
      term: json['term'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      status: NotificationStatus.fromString(json['status'] ?? 'sent'),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'sender_id': senderId,
      'sender_type': senderType,
      'title': title,
      'message': message,
      'short_message': shortMessage,
      'notification_type': notificationType.value,
      'priority': priority.value,
      'recipient_type': recipientType.value,
      'recipient_config': recipientConfig,
      'delivery_channels': deliveryChannels.map((e) => e.value).toList(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'attachments': attachments,
      'action_url': actionUrl,
      'action_text': actionText,
      'category': category,
      'tags': tags,
      'academic_year': academicYear,
      'term': term,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status.value,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
    };
  }

  AppNotification copyWith({
    bool? isRead,
    DateTime? readAt,
    NotificationStatus? status,
  }) {
    return AppNotification(
      id: id,
      tenantId: tenantId,
      senderId: senderId,
      senderType: senderType,
      title: title,
      message: message,
      shortMessage: shortMessage,
      notificationType: notificationType,
      priority: priority,
      recipientType: recipientType,
      recipientConfig: recipientConfig,
      deliveryChannels: deliveryChannels,
      scheduledAt: scheduledAt,
      expiresAt: expiresAt,
      attachments: attachments,
      actionUrl: actionUrl,
      actionText: actionText,
      category: category,
      tags: tags,
      academicYear: academicYear,
      term: term,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}

enum NotificationType {
  announcement('announcement'),
  assignment('assignment'),
  grade('grade'),
  attendance('attendance'),
  event('event'),
  reminder('reminder'),
  alert('alert'),
  general('general');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.general,
    );
  }
}

enum NotificationPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  const NotificationPriority(this.value);
  final String value;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}

enum RecipientType {
  individual('individual'),
  group('group'),
  class_level('class'),
  grade('grade'),
  all_students('all_students'),
  all_teachers('all_teachers'),
  broadcast('broadcast');

  const RecipientType(this.value);
  final String value;

  static RecipientType fromString(String value) {
    return RecipientType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecipientType.individual,
    );
  }
}

enum DeliveryChannel {
  inApp('in_app'),
  email('email'),
  sms('sms'),
  push('push');

  const DeliveryChannel(this.value);
  final String value;

  static DeliveryChannel fromString(String value) {
    return DeliveryChannel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DeliveryChannel.inApp,
    );
  }
}

enum NotificationStatus {
  draft('draft'),
  scheduled('scheduled'),
  sent('sent'),
  delivered('delivered'),
  failed('failed'),
  cancelled('cancelled');

  const NotificationStatus(this.value);
  final String value;

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationStatus.sent,
    );
  }
}

class NotificationStats {
  final int totalSent;
  final int totalRead;
  final int totalUnread;
  final int totalScheduled;
  final int totalFailed;
  final double readRate;
  final Map<String, int> typeBreakdown;
  final Map<String, int> priorityBreakdown;

  NotificationStats({
    required this.totalSent,
    required this.totalRead,
    required this.totalUnread,
    required this.totalScheduled,
    required this.totalFailed,
    required this.readRate,
    required this.typeBreakdown,
    required this.priorityBreakdown,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalSent: json['total_sent'] ?? 0,
      totalRead: json['total_read'] ?? 0,
      totalUnread: json['total_unread'] ?? 0,
      totalScheduled: json['total_scheduled'] ?? 0,
      totalFailed: json['total_failed'] ?? 0,
      readRate: (json['read_rate'] ?? 0).toDouble(),
      typeBreakdown: Map<String, int>.from(json['type_breakdown'] ?? {}),
      priorityBreakdown: Map<String, int>.from(json['priority_breakdown'] ?? {}),
    );
  }
}
