// services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/models/notification.dart';
import '../core/constants/app_constants.dart';

class NotificationService {
  static const String baseUrl = AppConstants.apiBaseUrl;

  // Send notification
  static Future<Map<String, dynamic>> sendNotification({
    required String senderId,
    required String senderType, // "teacher" or "school_authority"
    required String tenantId,
    required String title,
    required String message,
    required String notificationType,
    required String recipientType,
    Map<String, dynamic>? recipientConfig,
    String priority = "normal",
    List<String> deliveryChannels = const ["in_app"],
    String? category,
    List<String>? tags,
  }) async {
    try {
      final url = '$baseUrl/api/v1/school_authority/notifications/send?sender_id=$senderId&sender_type=$senderType';
      
      final requestBody = {
        "tenant_id": tenantId,
        "title": title,
        "message": message,
        "notification_type": notificationType,
        "priority": priority,
        "recipient_type": recipientType,
        "recipient_config": recipientConfig,
        "delivery_channels": deliveryChannels,
        "category": category,
        "tags": tags,
      };

      print('NotificationService: Sending notification to $url');
      print('NotificationService: Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('NotificationService: Response status: ${response.statusCode}');
      print('NotificationService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('NotificationService: Error sending notification: $e');
      throw Exception('Failed to send notification: $e');
    }
  }

  // Get notifications for user
  static Future<List<AppNotification>> getNotificationsForUser({
    required String userId,
    required String userType,
    required String tenantId,
    String? notificationType,
    String? status,
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        'user_type': userType,
        'tenant_id': tenantId,
        'unread_only': unreadOnly.toString(),
        'limit': limit.toString(),
      };

      if (notificationType != null) {
        queryParams['notification_type'] = notificationType;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/api/v1/school_authority/notifications/for-user/$userId')
          .replace(queryParameters: queryParams);

      print('NotificationService: Getting notifications from $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('NotificationService: Response status: ${response.statusCode}');
      print('NotificationService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AppNotification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get notifications: ${response.body}');
      }
    } catch (e) {
      print('NotificationService: Error getting notifications: $e');
      throw Exception('Failed to get notifications: $e');
    }
  }

  // Mark notification as read
  static Future<void> markAsRead({
    required String notificationId,
    required String userId,
  }) async {
    try {
      final url = '$baseUrl/api/v1/school_authority/notifications/$notificationId/mark-read?user_id=$userId';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.body}');
      }
    } catch (e) {
      print('NotificationService: Error marking as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
