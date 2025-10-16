// lib/features/notifications/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/notification.dart';
import '../../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;
  final String userType;
  final String tenantId;

  const NotificationsScreen({
    super.key,
    required this.userId,
    required this.userType,
    required this.tenantId,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppNotification> _allNotifications = [];
  List<AppNotification> _unreadNotifications = [];
  bool _isLoading = true;
  String? _error;
  bool _useMockData = false; // CHANGED: Default to false for real API

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (widget.userId.isEmpty || widget.tenantId.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_useMockData) {
        // Use mock data for demonstration
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        
        final mockAllNotifications = _generateMockNotifications();
        final mockUnreadNotifications = mockAllNotifications.where((n) => !n.isRead).toList();

        setState(() {
          _allNotifications = mockAllNotifications;
          _unreadNotifications = mockUnreadNotifications;
          _isLoading = false;
        });
      } else {
        // Real API calls with debug info
        print('DEBUG: Loading notifications...');
        print('DEBUG: UserId: ${widget.userId}');
        print('DEBUG: UserType: ${widget.userType}');
        print('DEBUG: TenantId: ${widget.tenantId}');
        
        final [allNotifications, unreadNotifications] = await Future.wait([
          NotificationService.getNotificationsForUser(
            userId: widget.userId,
            userType: widget.userType,
            tenantId: widget.tenantId,
            unreadOnly: false,
          ),
          NotificationService.getNotificationsForUser(
            userId: widget.userId,
            userType: widget.userType,
            tenantId: widget.tenantId,
            unreadOnly: true,
          ),
        ]);

        print('DEBUG: Loaded ${allNotifications.length} total notifications');
        print('DEBUG: Loaded ${unreadNotifications.length} unread notifications');

        setState(() {
          _allNotifications = allNotifications;
          _unreadNotifications = unreadNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error loading notifications: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All (${_allNotifications.length})',
            ),
            Tab(
              text: 'Unread (${_unreadNotifications.length})',
            ),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
        actions: [
          // Toggle between mock and real data (for development)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'toggle_data') {
                setState(() {
                  _useMockData = !_useMockData;
                });
                _loadNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_useMockData ? 'Using mock data' : 'Using real API'),
                    backgroundColor: Colors.blue,
                  ),
                );
              } else if (value == 'refresh') {
                _loadNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_data',
                child: Row(
                  children: [
                    Icon(_useMockData ? Icons.api : Icons.dashboard),
                    const SizedBox(width: 8),
                    Text(_useMockData ? 'Use Real API' : 'Use Mock Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
          if (_unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark All Read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading notifications...'),
                ],
              ),
            )
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationsList(_allNotifications),
                    _buildNotificationsList(_unreadNotifications),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading notifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[800]),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _useMockData = true;
                  });
                  _loadNotifications();
                },
                icon: const Icon(Icons.dashboard),
                label: const Text('Use Demo Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! 🎉',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: !notification.isRead
            ? BorderSide(color: AppTheme.primaryGreen.withOpacity(0.3), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.notificationType).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(notification.notificationType),
                      color: _getTypeColor(notification.notificationType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and Priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (notification.priority != NotificationPriority.normal)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(notification.priority),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  notification.priority.value.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _formatDateTime(notification.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (notification.category != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  notification.category!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Unread indicator
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Message
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14,
                  color: notification.isRead ? Colors.grey[700] : Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Tags
              if (notification.tags != null && notification.tags!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: notification.tags!.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              // Action Button
              if (notification.actionText != null && notification.actionUrl != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _handleActionTap(notification),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(notification.actionText!),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Keep all your existing helper methods
  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.assignment:
        return Icons.assignment;
      case NotificationType.grade:
        return Icons.grade;
      case NotificationType.attendance:
        return Icons.how_to_reg;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.alert:
        return Icons.warning;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return Colors.blue;
      case NotificationType.assignment:
        return Colors.orange;
      case NotificationType.grade:
        return Colors.green;
      case NotificationType.attendance:
        return Colors.purple;
      case NotificationType.event:
        return Colors.teal;
      case NotificationType.reminder:
        return Colors.amber;
      case NotificationType.alert:
        return Colors.red;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(AppNotification notification) async {
    if (!notification.isRead && !_useMockData) {
      try {
        await NotificationService.markAsRead(
          notificationId: notification.id,
          userId: widget.userId,
        );
      } catch (e) {
        print('Error marking notification as read: $e');
      }
    }

    if (!notification.isRead) {
      setState(() {
        final index = _allNotifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _allNotifications[index] = notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
        
        _unreadNotifications.removeWhere((n) => n.id == notification.id);
      });
    }
    
    // Navigate to notification details
    _showNotificationDetails(notification);
  }

  void _handleActionTap(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.launch, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text(notification.actionText ?? 'Action'),
          ],
        ),
        content: Text('Navigate to: ${notification.actionUrl}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Would navigate to: ${notification.actionUrl}'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getTypeIcon(notification.notificationType),
              color: _getTypeColor(notification.notificationType),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Metadata
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sent: ${_formatDateTime(notification.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (notification.isRead && notification.readAt != null)
                      Text(
                        'Read: ${_formatDateTime(notification.readAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    Text(
                      'Priority: ${notification.priority.value.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getPriorityColor(notification.priority),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                notification.message,
                style: const TextStyle(fontSize: 14),
              ),
              
              if (notification.category != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Category: ${notification.category}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              
              if (notification.tags != null && notification.tags!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: notification.tags!.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      backgroundColor: Colors.blue[100],
                      labelStyle: const TextStyle(fontSize: 10),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (notification.actionText != null && notification.actionUrl != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _handleActionTap(notification);
              },
              icon: const Icon(Icons.launch, size: 16),
              label: Text(notification.actionText!),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    if (_unreadNotifications.isEmpty) return;

    try {
      setState(() {
        for (int i = 0; i < _allNotifications.length; i++) {
          if (!_allNotifications[i].isRead) {
            _allNotifications[i] = _allNotifications[i].copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );
          }
        }
        _unreadNotifications.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Keep your existing mock data method unchanged
  List<AppNotification> _generateMockNotifications() {
    // ... your existing mock data method
    return []; // Add your existing mock data here
  }
}
