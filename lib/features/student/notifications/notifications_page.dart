
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ==========================================
// NOTIFICATION MODEL
// ==========================================

class RideNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final String time;
  final IconData icon;
  final Color color;
  bool isRead;

  RideNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

// ==========================================
// LOCAL NOTIFICATION STORE
// Demo data only - backend not connected yet.
// ==========================================

class NotificationStore {
  static final List<RideNotification> notifications = [
    RideNotification(
      id: 1,
      title: 'Ride Request Accepted',
      message: 'Alex Santos accepted your ride request to CMDI Main Campus.',
      type: 'Ride Updates',
      time: '5 minutes ago',
      icon: Icons.check_circle_outline,
      color: const Color(0xFF16A36A),
    ),
    RideNotification(
      id: 2,
      title: 'Driver is Arriving',
      message: 'Your driver is getting ready for your scheduled pickup.',
      type: 'Ride Updates',
      time: '30 minutes ago',
      icon: Icons.directions_car_outlined,
      color: AppColors.primary,
    ),
    RideNotification(
      id: 3,
      title: 'Upcoming Ride Reminder',
      message: 'Your ride to CMDI is scheduled for tomorrow at 6:30 AM.',
      type: 'Reminders',
      time: 'Yesterday',
      icon: Icons.access_time,
      color: const Color(0xFFE99A27),
    ),
    RideNotification(
      id: 4,
      title: 'New Message',
      message: 'Alex Santos sent you a message about your pickup location.',
      type: 'Messages',
      time: 'Yesterday',
      icon: Icons.chat_bubble_outline,
      color: const Color(0xFF3685D8),
    ),
    RideNotification(
      id: 5,
      title: 'Lost Item Update',
      message: 'There is an update regarding your reported lost item.',
      type: 'Lost and Found',
      time: '2 days ago',
      icon: Icons.inventory_2_outlined,
      color: const Color(0xFF8B5CC7),
      isRead: true,
    ),
  ];

  static int get unreadCount {
    return notifications.where((item) => !item.isRead).length;
  }

  static void markAsRead(RideNotification notification) {
    notification.isRead = true;
  }

  static void markAllAsRead() {
    for (final notification in notifications) {
      notification.isRead = true;
    }
  }
}

// ==========================================
// NOTIFICATIONS PAGE
// ==========================================

class NotificationsPage extends StatefulWidget {
  final VoidCallback? onChanged;

  const NotificationsPage({
    super.key,
    this.onChanged,
  });

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String selectedFilter = 'All';

  List<RideNotification> get filteredNotifications {
    if (selectedFilter == 'Unread') {
      return NotificationStore.notifications
          .where((item) => !item.isRead)
          .toList();
    }

    if (selectedFilter == 'Read') {
      return NotificationStore.notifications
          .where((item) => item.isRead)
          .toList();
    }

    return NotificationStore.notifications;
  }

  void _markAsRead(RideNotification notification) {
    setState(() {
      NotificationStore.markAsRead(notification);
    });

    widget.onChanged?.call();
  }

  void _markAllAsRead() {
    setState(() {
      NotificationStore.markAllAsRead();
    });

    widget.onChanged?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openNotification(RideNotification notification) {
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${notification.title} selected.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${NotificationStore.unreadCount} unread notifications',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (NotificationStore.unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // FILTER BUTTONS
  // ==========================================

  Widget _buildFilters() {
    const filters = ['All', 'Unread', 'Read'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    filter,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // NOTIFICATION CARD
  // ==========================================

  Widget _buildNotificationCard(
    RideNotification notification,
  ) {
    return InkWell(
      onTap: () => _openNotification(notification),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : const Color(0xFFF5F0FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : const Color(0xFFE3D8FF),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: notification.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification.icon,
                color: notification.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        notification.time,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EAFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          notification.type,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 35,
          vertical: 70,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAFF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.primary,
                size: 35,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              selectedFilter == 'Unread'
                  ? 'You have no unread notifications.'
                  : selectedFilter == 'Read'
                      ? 'You have no read notifications.'
                      : 'You do not have any notifications yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final items = filteredNotifications;

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilters(),
          const SizedBox(height: 17),
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      20,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        items[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
