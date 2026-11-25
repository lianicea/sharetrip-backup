import 'package:flutter/material.dart';
import '../profile/profile_page.dart';
import '../my_rides/my_rides_page.dart';
import '../find_ride/find_ride_page.dart';
import '../chat/chat_page.dart';
import '../../../core/constants/app_colors.dart';

class StudentHomePage extends StatefulWidget {
  final String studentName;
  final String schoolEmail;
  final String course;

  const StudentHomePage({
    super.key,
    this.studentName = 'Andrea Jimenez',
    this.schoolEmail = 'student@cmdi.edu.ph',
    this.course = 'BS Information Systems',
  });

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int selectedIndex = 0;

  // ==========================================
  // NOTIFICATIONS
  // ==========================================

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Ride Request Confirmed',
      'message': 'Your ride request with Alex Santos has been confirmed.',
      'time': 'Just now',
      'category': 'Ride Updates',
      'icon': Icons.check_circle_outline,
      'color': Colors.green,
      'read': false,
    },
    {
      'title': 'Driver is on the Way',
      'message': 'Your driver is preparing for your scheduled trip.',
      'time': '10 minutes ago',
      'category': 'Ride Updates',
      'icon': Icons.directions_car_outlined,
      'color': Colors.blue,
      'read': false,
    },
    {
      'title': 'Upcoming Ride Reminder',
      'message': 'You have a scheduled ride today at 6:30 AM.',
      'time': '1 hour ago',
      'category': 'Reminders',
      'icon': Icons.access_time,
      'color': Colors.orange,
      'read': false,
    },
    {
      'title': 'Welcome to ShareTrip!',
      'message': 'Thank you for using ShareTrip. Travel safely!',
      'time': 'Yesterday',
      'category': 'System',
      'icon': Icons.notifications_active_outlined,
      'color': AppColors.primary,
      'read': true,
    },
  ];

  int get unreadCount =>
      notifications.where((n) => n['read'] == false).length;

  // ==========================================
  // NAVIGATION
  // ==========================================

  final List<Map<String, dynamic>> navItems = [
    {
      'title': 'Home',
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
    },
    {
      'title': 'Find Ride',
      'icon': Icons.search,
      'activeIcon': Icons.search,
    },
    {
      'title': 'My Rides',
      'icon': Icons.alt_route,
      'activeIcon': Icons.alt_route,
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications_none,
      'activeIcon': Icons.notifications,
    },
    {
      'title': 'Messages',
      'icon': Icons.chat_bubble_outline,
      'activeIcon': Icons.chat_bubble,
    },
    {
      'title': 'Profile',
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
    },
  ];

  // ==========================================
  // SAMPLE RIDES
  // ==========================================

  final List<Map<String, String>> availableRides = [
    {
      'driver': 'Alex Santos',
      'vehicle': 'Toyota Vios · ABC 1234',
      'route': 'Bitin → CMDI Main Campus',
      'departure': '6:30 AM',
      'seats': '3 seats',
      'fare': '₱25',
      'rating': '4.8',
    },
    {
      'driver': 'Maria Reyes',
      'vehicle': 'Honda Click 160',
      'route': 'Maitim → CMDI Main Campus',
      'departure': '7:00 AM',
      'seats': '1 seat',
      'fare': '₱20',
      'rating': '4.9',
    },
  ];

  final List<Map<String, String>> recommendedRoutes = [
    {
      'route': 'Bitin → CMDI',
      'description': 'Most popular · ~15 min',
    },
    {
      'route': 'Maitim → CMDI',
      'description': 'Morning commute · ~20 min',
    },
    {
      'route': 'CMDI → Tranca',
      'description': 'Afternoon return · ~15 min',
    },
    {
      'route': 'Tranca → CMDI',
      'description': 'Direct route · ~18 min',
    },
  ];

  // ==========================================
  // GENERAL FUNCTIONS
  // ==========================================

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void _changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // FRONTEND-ONLY DRIVER CHAT
  void _openDriverChat({
    required String driverName,
    required String vehicle,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverChatPage(
          driverName: driverName,
          vehicle: vehicle,
        ),
      ),
    );
  }

  // ==========================================
  // NOTIFICATION ACTIONS
  // ==========================================

  void _markNotificationRead(int index) {
    if (index < 0 || index >= notifications.length) return;
    if (notifications[index]['read'] == true) return;

    setState(() {
      notifications[index]['read'] = true;
    });
  }

  void _markAllAsRead() {
    if (unreadCount == 0) return;

    setState(() {
      for (final notification in notifications) {
        notification['read'] = true;
      }
    });

    _showMessage('All notifications marked as read.');
  }

  Future<void> _deleteNotification(int index) async {
    if (index < 0 || index >= notifications.length) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Notification?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this notification?',
            style: TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      if (index >= notifications.length) return;

      setState(() {
        notifications.removeAt(index);
      });

      _showMessage('Notification deleted.');
    }
  }

  void _clearAllNotifications() {
    if (notifications.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Clear All Notifications?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This will permanently remove all notifications from this list.',
            style: TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  notifications.clear();
                });

                _showMessage('All notifications cleared.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // NOTIFICATIONS PAGE
  // ==========================================

  Widget _buildNotifications() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                unreadCount == 0
                    ? 'You are all caught up!'
                    : 'You have $unreadCount unread notifications.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // NOTIFICATION ACTIONS

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 17, 18, 10),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Notifications',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              if (notifications.isNotEmpty) ...[
                if (unreadCount > 0)
                  TextButton(
                    onPressed: _markAllAsRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                      ),
                    ),
                    child: const Text(
                      'Mark all as read',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'clear') {
                      _clearAllNotifications();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_sweep_outlined,
                            color: Colors.red,
                            size: 19,
                          ),
                          SizedBox(width: 9),
                          Text('Clear all notifications'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // NOTIFICATION LIST

        Expanded(
          child: notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 15),
                      const Text(
                        'No notifications yet.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'You are all caught up!',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final bool isRead = notification['read'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 11),
                      decoration: BoxDecoration(
                        color: isRead
                            ? Colors.white
                            : const Color(0xFFF2EEFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isRead
                              ? AppColors.border
                              : AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          _markNotificationRead(index);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 43,
                                height: 43,
                                decoration: BoxDecoration(
                                  color: (notification['color'] as Color)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  notification['icon'] as IconData,
                                  color: notification['color'] as Color,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(width: 11),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notification['title'] as String,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (!isRead)
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
                                      notification['message'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),

                                    const SizedBox(height: 9),

                                    Wrap(
                                      spacing: 9,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          notification['category'] as String,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          notification['time'] as String,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // DELETE BUTTON

                              IconButton(
                                onPressed: () {
                                  _deleteNotification(index);
                                },
                                tooltip: 'Delete notification',
                                constraints: const BoxConstraints(
                                  minWidth: 34,
                                  minHeight: 34,
                                ),
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // REQUEST RIDE
  // ==========================================

  Future<void> _requestRide(Map<String, String> ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Request This Ride?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride['driver'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                ride['route'] ?? '',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 9),
              Text(
                'Departure: ${ride['departure']}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                'Fare: ${ride['fare']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Demo preview only. Actual ride requests will be connected to the backend later.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _showMessage(
        'Demo request confirmed. Backend connection is still pending.',
      );
    }
  }

  // ==========================================
  // HOME HEADER
  // ==========================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 27),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$greeting, ${widget.studentName.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'STUDENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Where are you going today?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SEARCH BAR
  // ==========================================

  Widget _buildSearchBar() {
    return InkWell(
      onTap: () => _changeTab(1),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 47,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 19,
            ),
            SizedBox(width: 10),
            Text(
              'Search destination or route...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // QUICK ACTION CARD
  // ==========================================

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION HEADER
  // ==========================================

  Widget _sectionHeader(
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // CURRENT RIDE CARD
  // ==========================================

  Widget _buildCurrentRideCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF211443),
            Color(0xFF47228D),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CURRENT RIDE · SAMPLE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active Demo',
                  style: TextStyle(
                    color: Color(0xFF5DE4A5),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Alex Santos · Toyota Vios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _currentRideInfo('Route', 'Bitin → CMDI'),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _currentRideInfo('Departure', '6:30 AM'),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _rideActionButton(
                  'Track Ride',
                  Icons.location_on_outlined,
                  () => _showMessage(
                    'Live driver tracking will be connected after the driver app is ready.',
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _rideActionButton(
                  'View Details',
                  Icons.receipt_long_outlined,
                  () => _showMessage(
                    'Ride details page is coming next.',
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _rideActionButton(
                  'Contact',
                  Icons.chat_outlined,
                  () => _openDriverChat(
                    driverName: 'Alex Santos',
                    vehicle: 'Toyota Vios · ABC 1234',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currentRideInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rideActionButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // AVAILABLE RIDE CARD
  // ==========================================

  Widget _buildAvailableRideCard(Map<String, String> ride) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EAFF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.directions_car_outlined,
                        color: AppColors.primary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride['driver']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ride['vehicle']!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.star,
                      color: Color(0xFFE5A72B),
                      size: 17,
                    ),
                    Text(
                      ride['rating']!,
                      style: const TextStyle(
                        color: Color(0xFFC18A19),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.route_outlined,
                      color: AppColors.primary,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        ride['route']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: _rideInfoBox(
                        'DEPARTURE',
                        ride['departure']!,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _rideInfoBox(
                        'AVAILABLE',
                        ride['seats']!,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _rideInfoBox(
                        'FARE',
                        ride['fare']!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: ElevatedButton(
                      onPressed: () => _requestRide(ride),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: const Text(
                        'Request Ride',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rideInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // RECOMMENDED ROUTE CARD
  // ==========================================

  Widget _buildRecommendedRoute(String route, String description) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.alt_route,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HOME CONTENT
  // ==========================================

  Widget _buildHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 19, 19, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 17),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _quickActionCard(
                            icon: Icons.search,
                            title: 'Find a Ride',
                            subtitle: 'Search available rides',
                            onTap: () => _changeTab(1),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _quickActionCard(
                            icon: Icons.alt_route,
                            title: 'My Rides',
                            subtitle: 'Current & upcoming',
                            onTap: () => _changeTab(2),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _quickActionCard(
                            icon: Icons.favorite_border,
                            title: 'Saved Places',
                            subtitle: 'Frequent destinations',
                            onTap: () => _showMessage(
                              'Saved Places page is coming next.',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _quickActionCard(
                            icon: Icons.access_time,
                            title: 'Ride History',
                            subtitle: 'Previous rides',
                            onTap: () => _changeTab(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                _buildCurrentRideCard(),
                const SizedBox(height: 22),
                _sectionHeader(
                  'Available Rides',
                  action: 'See all',
                  onAction: () => _changeTab(1),
                ),
                const SizedBox(height: 9),
                ...availableRides.map(_buildAvailableRideCard),
                const SizedBox(height: 12),
                _sectionHeader('Recommended Routes'),
                const SizedBox(height: 9),
                ...recommendedRoutes.map(
                  (route) => _buildRecommendedRoute(
                    route['route']!,
                    route['description']!,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FAF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFC9F0E3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF16866C),
                        size: 25,
                      ),
                      SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Safety Matters',
                              style: TextStyle(
                                color: Color(0xFF126B57),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Explore verified rides and safety tools.',
                              style: TextStyle(
                                color: Color(0xFF397E70),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // COMING SOON
  // ==========================================

  Widget _buildComingSoon() {
    final titles = [
      '',
      'Find a Ride',
      'My Rides',
      'Notifications',
      'Profile',
    ];

    final descriptions = [
      '',
      'Search and compare available campus rides.',
      'Manage your active, upcoming and completed trips.',
      'Check ride updates, messages and reminders.',
      'Manage your student information and account.',
    ];

    final icons = [
      Icons.home,
      Icons.search,
      Icons.alt_route,
      Icons.notifications_outlined,
      Icons.person_outline,
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icons[selectedIndex],
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              titles[selectedIndex],
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              descriptions[selectedIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 19),
            const Text(
              'This feature will be developed in the next phase.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton(
              onPressed: () => _changeTab(0),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM NAVIGATION
  // ==========================================

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.7,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 7,
          ),
          child: Row(
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final selected = selectedIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => _changeTab(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 1,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              selected
                                  ? item['activeIcon'] as IconData
                                  : item['icon'] as IconData,
                              size: 21,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            if (index == 3 && unreadCount > 0)
                              Positioned(
                                right: -7,
                                top: -5,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 15,
                                    minHeight: 15,
                                  ),
                                  child: Text(
                                    unreadCount > 9
                                        ? '9+'
                                        : '$unreadCount',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

    // ==========================================
  // BUILD
  // ==========================================

  
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: selectedIndex == 0
          ? _buildHome()
          : selectedIndex == 1
              ? const FindRidePage()
              : selectedIndex == 2
                  ? const MyRidesPage()
                  : selectedIndex == 3
                      ? _buildNotifications()
                      : selectedIndex == 4
                          ? const ChatPage()
                          : ProfilePage(
                              studentName: widget.studentName,
                              schoolEmail: widget.schoolEmail,
                              course: widget.course,
                            ),
    ),
    bottomNavigationBar: _buildBottomNavigation(),
  );
}

}



// =====================================================
// DRIVER CHAT PAGE (FRONTEND DEMO ONLY)
// =====================================================
class DriverChatPage extends StatefulWidget {
  final String driverName;
  final String vehicle;

  const DriverChatPage({
    super.key,
    required this.driverName,
    required this.vehicle,
  });

  @override
  State<DriverChatPage> createState() => _DriverChatPageState();
}

class _DriverChatPageState extends State<DriverChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your driver. Please message me if you have any updates.',
      'isMe': false,
      'time': '8:30 AM',
    },
    {
      'text': 'Hello, noted. Thank you!',
      'isMe': true,
      'time': '8:32 AM',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
    });
    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.driverName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.vehicle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            color: const Color(0xFFECE7FA),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Demo chat only. Messages are not sent to a real driver.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isMe = message['isMe'] == true;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.76,
                    ),
                    margin: const EdgeInsets.only(bottom: 11),
                    padding: const EdgeInsets.fromLTRB(13, 10, 13, 7),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isMe ? 15 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message['text'] as String,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.textPrimary,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['time'] as String,
                          style: TextStyle(
                            color: isMe ? Colors.white70 : AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: const Color(0xFFF3F1F8),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _sendMessage,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
