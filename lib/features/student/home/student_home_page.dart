
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/sharetrip_auth_service.dart';
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
    this.studentName = '',
    this.schoolEmail = '',
    this.course = '',
  });

  @override
  State<StudentHomePage> createState() =>
      _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  int selectedIndex = 0;

  bool _isLoading = true;
  bool _isRequesting = false;
  String? _errorMessage;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _currentRide;

  List<Map<String, dynamic>> availableRides = [];
  List<Map<String, dynamic>> notifications = [];

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

  String get _userId {
    return _supabase.auth.currentUser?.id ?? '';
  }

  String get _studentName {
    final name = _profile?['full_name']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return widget.studentName.isNotEmpty
        ? widget.studentName
        : 'Student';
  }

  String get _schoolEmail {
    return _profile?['email']?.toString() ??
        widget.schoolEmail;
  }

  String get _course {
    final details = _profile?['details'];

    if (details is Map && details['course'] != null) {
      return details['course'].toString();
    }

    return widget.course;
  }

  int get unreadCount {
    return notifications.where(
      (item) => item['is_read'] != true,
    ).length;
  }

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';

    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // ==========================================
  // LOAD SUPABASE DATA
  // ==========================================

 
Future<void> _loadHomeData() async {
  if (_userId.isEmpty) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = 'Please log in to access your account.';
    });

    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final tasks = <String, Future<void> Function()>{
    'PROFILE': _loadProfile,
    'AVAILABLE RIDES': _loadAvailableRides,
    'NOTIFICATIONS': _loadNotifications,
    'CURRENT RIDE': _loadCurrentRide,
  };

  final errors = <String>[];

  for (final task in tasks.entries) {
    try {
      await task.value();
      debugPrint('SUCCESS: ${task.key}');
    } on PostgrestException catch (error, stackTrace) {
      debugPrint('FAILED: ${task.key}');
      debugPrint('MESSAGE: ${error.message}');
      debugPrint('CODE: ${error.code}');
      debugPrint('DETAILS: ${error.details}');
      debugPrint('HINT: ${error.hint}');
      debugPrintStack(stackTrace: stackTrace);

      errors.add(task.key);
    } catch (error, stackTrace) {
      debugPrint('FAILED: ${task.key}');
      debugPrint('ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errors.add(task.key);
    }
  }

  if (!mounted) return;

  setState(() {
    _isLoading = false;

    if (errors.length == tasks.length) {
      _errorMessage = 'Unable to load your account data. '
          'Please check your Supabase configuration.';
    }
  });

  if (errors.isNotEmpty) {
    debugPrint('HOME LOADING FAILED TASKS: ${errors.join(', ')}');
  }
}


  // ==========================================
  // STUDENT PROFILE
  // ==========================================

  Future<void> _loadProfile() async {
    final result = await _supabase
        .from('profiles')
        .select(
          'id, email, full_name, role, details, avatar_url',
        )
        .eq('id', _userId)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      _profile = result;
    });
  }

  // ==========================================
  // AVAILABLE RIDES
  // ==========================================

  Future<void> _loadAvailableRides() async {
    final result = await _supabase
        .from('rides')
        .select()
        .eq('status', 'open')
        .gt(
          'departure_at',
          DateTime.now().toUtc().toIso8601String(),
        )
        .gt('seats_available', 0)
        .order('departure_at')
        .limit(5);

    final rides = List<Map<String, dynamic>>.from(result);

    if (rides.isEmpty) {
      if (!mounted) return;

      setState(() {
        availableRides = [];
      });

      return;
    }

    final driverIds = rides
        .map((ride) => ride['driver_id'].toString())
        .toSet()
        .toList();

    final profiles = await _supabase
        .from('user_public_profiles')
        .select('id, full_name, avatar_url')
        .inFilter('id', driverIds);

    final driverMap = {
      for (final profile in profiles)
        profile['id'].toString(): profile,
    };

    final vehicleIds = rides
        .where((ride) => ride['vehicle_id'] != null)
        .map((ride) => ride['vehicle_id'].toString())
        .toSet()
        .toList();

    Map<String, dynamic> vehicleMap = {};

    if (vehicleIds.isNotEmpty) {
      final vehicles = await _supabase
          .from('vehicles')
          .select()
          .inFilter('id', vehicleIds);

      vehicleMap = {
        for (final vehicle in vehicles)
          vehicle['id'].toString(): vehicle,
      };
    }

    final formattedRides = rides.map((ride) {
      final driverId = ride['driver_id'].toString();

      final driver = driverMap[driverId];

      final vehicleId = ride['vehicle_id']?.toString();

      final vehicle = vehicleId == null
          ? null
          : vehicleMap[vehicleId];

      return <String, dynamic>{
        ...ride,
        'driver_name': driver?['full_name'] ?? 'Driver',
        'driver_avatar': driver?['avatar_url'],
        'vehicle_name': _vehicleName(ride, vehicle),
      };
    }).toList();

    if (!mounted) return;

    setState(() {
      availableRides = formattedRides;
    });
  }

  String _vehicleName(
    Map<String, dynamic> ride,
    Map<String, dynamic>? vehicle,
  ) {
    if (vehicle != null) {
      final parts = [
        vehicle['make'],
        vehicle['model'],
      ].where(
        (value) =>
            value != null && value.toString().trim().isNotEmpty,
      );

      final name = parts.join(' ');

      if (name.isNotEmpty) return name;

      return vehicle['vehicle_type']?.toString() ?? 'Vehicle';
    }

    return ride['vehicle_type']?.toString() ?? 'Vehicle';
  }

  // ==========================================
  // CURRENT RIDE
  // ==========================================

  Future<void> _loadCurrentRide() async {
    final requestResult = await _supabase
        .from('ride_requests')
        .select('id, ride_id, status, created_at')
        .eq('student_id', _userId)
        .eq('status', 'accepted')
        .order('created_at', ascending: false)
        .limit(1);

    if (requestResult.isEmpty) {
      if (!mounted) return;

      setState(() {
        _currentRide = null;
      });

      return;
    }

    final request = requestResult.first;
    final rideId = request['ride_id'];

    final rideResult = await _supabase
        .from('rides')
        .select()
        .eq('id', rideId)
        .maybeSingle();

    if (rideResult == null) {
      if (!mounted) return;

      setState(() {
        _currentRide = null;
      });

      return;
    }

    final driverResult = await _supabase
        .from('user_public_profiles')
        .select('id, full_name')
        .eq('id', rideResult['driver_id'])
        .maybeSingle();

    final combined = <String, dynamic>{
      ...rideResult,
      'request_id': request['id'],
      'driver_name': driverResult?['full_name'] ?? 'Driver',
    };

    if (!mounted) return;

    setState(() {
      _currentRide = combined;
    });
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================

  Future<void> _loadNotifications() async {
    final result = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(50);

    if (!mounted) return;

    setState(() {
      notifications = List<Map<String, dynamic>>.from(result);
    });
  }

  IconData _notificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'ride':
      case 'ride_update':
        return Icons.directions_car_outlined;

      case 'booking':
      case 'ride_request':
        return Icons.receipt_long_outlined;

      case 'message':
        return Icons.chat_bubble_outline;

      case 'reminder':
        return Icons.access_time;

      default:
        return Icons.notifications_outlined;
    }
  }

  Color _notificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'ride':
      case 'ride_update':
        return Colors.green;

      case 'booking':
      case 'ride_request':
        return Colors.blue;

      case 'message':
        return AppColors.primary;

      case 'reminder':
        return Colors.orange;

      default:
        return AppColors.primary;
    }
  }

  String _formatTime(dynamic date) {
    if (date == null) return '';

    final parsed = DateTime.tryParse(date.toString());

    if (parsed == null) return '';

    return TimeOfDay.fromDateTime(
      parsed.toLocal(),
    ).format(context);
  }

  Future<void> _markNotificationRead(
    Map<String, dynamic> notification,
  ) async {
    if (notification['is_read'] == true) return;

    final id = notification['id'];

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id)
          .eq('user_id', _userId);

      if (!mounted) return;

      setState(() {
        final index = notifications.indexWhere(
          (item) => item['id'] == id,
        );

        if (index != -1) {
          notifications[index]['is_read'] = true;
        }
      });
    } catch (error) {
      _showMessage('Unable to update notification.');
    }
  }

  Future<void> _markAllAsRead() async {
    if (unreadCount == 0) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _userId)
          .eq('is_read', false);

      if (!mounted) return;

      setState(() {
        for (final item in notifications) {
          item['is_read'] = true;
        }
      });

      _showMessage('All notifications marked as read.');
    } catch (error) {
      _showMessage('Unable to update notifications.');
    }
  }

  Future<void> _deleteNotification(
    Map<String, dynamic> notification,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Notification?'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notification['id'])
          .eq('user_id', _userId);

      if (!mounted) return;

      setState(() {
        notifications.removeWhere(
          (item) => item['id'] == notification['id'],
        );
      });

      _showMessage('Notification deleted.');
    } catch (error) {
      _showMessage('Unable to delete notification.');
    }
  }

  Future<void> _clearAllNotifications() async {
    if (notifications.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text(
          'This will remove all your notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', _userId);

      if (!mounted) return;

      setState(() {
        notifications.clear();
      });

      _showMessage('All notifications cleared.');
    } catch (error) {
      _showMessage('Unable to clear notifications.');
    }
  }

  // ==========================================
  // RIDE REQUEST
  // ==========================================

  Future<void> _requestRide(
    Map<String, dynamic> ride,
  ) async {
    if (_isRequesting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request This Ride?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ride['driver_name']?.toString() ?? 'Driver',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${ride['pickup']} → ${ride['destination']}',
            ),
            const SizedBox(height: 8),
            Text(
              'Departure: ${_formatTime(ride['departure_at'])}',
            ),
            const SizedBox(height: 8),
            Text(
              'Fare: ₱${ride['fare']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your request will be sent to the driver for approval.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      await _supabase.from('ride_requests').insert({
        'ride_id': ride['id'],
        'student_id': _userId,
        'status': 'pending',
      });

      if (!mounted) return;

      _showMessage('Ride request successfully submitted.');

      await _loadHomeData();
    } on PostgrestException catch (error) {
      if (!mounted) return;

      if (error.code == '23505') {
        _showMessage('You already requested this ride.');
      } else {
        debugPrint('Ride request error: ${error.message}');
        _showMessage('Unable to submit ride request.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Something went wrong.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  // ==========================================
  // GENERAL FUNCTIONS
  // ==========================================

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

  // ==========================================
  // HEADER
  // ==========================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 27),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$greeting, ${_studentName.split(' ').first}',
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
                  color: Colors.white.withOpacity(0.12),
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
  // QUICK ACTION
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
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.border.withOpacity(0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
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
    final ride = _currentRide!;

    final route =
        '${ride['pickup']} → ${ride['destination']}';

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
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR CONFIRMED RIDE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.verified,
                color: Color(0xFF5DE4A5),
                size: 19,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ride['driver_name']?.toString() ?? 'Driver',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            route,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.white70,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(ride['departure_at']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.payments_outlined,
                color: Colors.white70,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                '₱${ride['fare']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _changeTab(2),
              icon: const Icon(
                Icons.receipt_long_outlined,
                size: 16,
              ),
              label: const Text(
                'View My Rides',
                style: TextStyle(fontSize: 11),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // AVAILABLE RIDE CARD
  // ==========================================

  Widget _buildAvailableRideCard(
    Map<String, dynamic> ride,
  ) {
    final fare = ride['fare'];
    final departure = _formatTime(ride['departure_at']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                            ride['driver_name']?.toString() ?? 'Driver',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ride['vehicle_name']?.toString() ?? 'Vehicle',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified_outlined,
                      color: AppColors.primary,
                      size: 18,
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
                        '${ride['pickup']} → ${ride['destination']}',
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
                        departure,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _rideInfoBox(
                        'AVAILABLE',
                        '${ride['seats_available']} seats',
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _rideInfoBox(
                        'FARE',
                        '₱$fare',
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
                      onPressed: _isRequesting
                          ? null
                          : () => _requestRide(ride),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.transparent,
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
  // EMPTY STATE
  // ==========================================

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 27,
        horizontal: 15,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 37,
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HOME CONTENT
  // ==========================================

  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _loadHomeData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                      final cardWidth =
                          (constraints.maxWidth - 12) / 2;

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
                              subtitle: 'Manage your trips',
                              onTap: () => _changeTab(2),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _quickActionCard(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              subtitle: 'Check ride updates',
                              onTap: () => _changeTab(3),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _quickActionCard(
                              icon: Icons.chat_outlined,
                              title: 'Messages',
                              subtitle: 'Contact your driver',
                              onTap: () => _changeTab(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  if (_currentRide != null) ...[
                    _sectionHeader('Current Ride'),
                    const SizedBox(height: 9),
                    _buildCurrentRideCard(),
                    const SizedBox(height: 22),
                  ],

                  _sectionHeader(
                    'Available Rides',
                    action: 'See all',
                    onAction: () => _changeTab(1),
                  ),
                  const SizedBox(height: 9),

                  if (availableRides.isEmpty)
                    _buildEmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'No Available Rides',
                      description:
                          'There are currently no rides available. Please check again later.',
                    )
                  else
                    ...availableRides.map(_buildAvailableRideCard),

                  const SizedBox(height: 12),

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
      ),
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
                  onSelected: (value) {
                    if (value == 'clear') {
                      _clearAllNotifications();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear',
                      child: Text('Clear all notifications'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: notifications.isEmpty
              ? _buildEmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'No Notifications Yet',
                  description:
                      'Your ride updates and messages will appear here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];

                    final isRead = item['is_read'] == true;

                    final type =
                        item['type']?.toString() ?? 'general';

                    final color = _notificationColor(type);

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
                              : AppColors.primary.withOpacity(0.25),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _markNotificationRead(item),
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
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _notificationIcon(type),
                                  color: color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['title']?.toString() ??
                                                'Notification',
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
                                            decoration:
                                                const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item['body']?.toString() ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatTime(item['created_at']),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _deleteNotification(item),
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
  // LOADING / ERROR
  // ==========================================

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 13),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _loadHomeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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
            color: Colors.black.withOpacity(0.04),
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
    Widget page;

    if (_isLoading) {
      page = _buildLoading();
    } else if (_errorMessage != null) {
      page = _buildError();
    } else {
      switch (selectedIndex) {
        case 0:
          page = _buildHome();
          break;

        case 1:
          page = const FindRidePage();
          break;

        case 2:
          page = const MyRidesPage();
          break;

        case 3:
          page = _buildNotifications();
          break;

        case 4:
          page = const ChatPage();
          break;

        case 5:
          page = ProfilePage(
            studentName: _studentName,
            schoolEmail: _schoolEmail,
            course: _course,
          );
          break;

        default:
          page = _buildHome();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: page,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
