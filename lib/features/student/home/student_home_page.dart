import '../my_rides/my_rides_page.dart';
import '../find_ride/find_ride_page.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

// ==========================================
// STUDENT HOME PAGE
// ==========================================

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
  State<StudentHomePage> createState() =>
      _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int selectedIndex = 0;

  // ==========================================
  // BOTTOM NAVIGATION
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
      'title': 'Profile',
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
    },
  ];

  // ==========================================
  // SAMPLE AVAILABLE RIDES
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

  // ==========================================
  // RECOMMENDED ROUTES
  // ==========================================

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
  // GREETING
  // ==========================================

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  // ==========================================
  // NAVIGATION
  // ==========================================

  void _changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==========================================
  // REQUEST RIDE
  // ==========================================

  Future<void> _requestRide(
    Map<String, String> ride,
  ) async {
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
      padding: const EdgeInsets.fromLTRB(
        22,
        25,
        22,
        27,
      ),

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
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white24,
                  ),
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
      onTap: () {
        _changeTab(1);
      },

      borderRadius: BorderRadius.circular(13),

      child: Container(
        height: 47,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: AppColors.border,
          ),
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
          // HEADER

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
                  color: Colors.green.withOpacity(0.15),
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
                child: _currentRideInfo(
                  'Route',
                  'Bitin → CMDI',
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _currentRideInfo(
                  'Departure',
                  '6:30 AM',
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ACTION BUTTONS

          Row(
            children: [
              Expanded(
                child: _rideActionButton(
                  'Track Ride',
                  Icons.location_on_outlined,
                  () => _showMessage(
                    'Live ride tracking will be added in the Maps phase.',
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
                  () => _showMessage(
                    'Driver messaging will be added in the Chat phase.',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currentRideInfo(
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
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
      color: Colors.white.withOpacity(0.08),
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
            border: Border.all(
              color: Colors.white24,
            ),
          ),

          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),

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

  Widget _buildAvailableRideCard(
    Map<String, String> ride,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),

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
          // TOP PURPLE STRIP

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
                // DRIVER INFORMATION

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

                // ROUTE

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

                // RIDE INFORMATION

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

                // REQUEST BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 42,

                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(11),
                    ),

                    child: ElevatedButton(
                      onPressed: () {
                        _requestRide(ride);
                      },

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

  Widget _rideInfoBox(
    String label,
    String value,
  ) {
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

  Widget _buildRecommendedRoute(
    String route,
    String description,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
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
          // HEADER

          _buildHeader(),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              19,
              19,
              19,
              25,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SEARCH BAR

                _buildSearchBar(),

                const SizedBox(height: 17),

                // QUICK ACTIONS

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

                // CURRENT RIDE

                _buildCurrentRideCard(),

                const SizedBox(height: 22),

                // AVAILABLE RIDES

                _sectionHeader(
                  'Available Rides',
                  action: 'See all',
                  onAction: () => _changeTab(1),
                ),

                const SizedBox(height: 9),

                ...availableRides.map(
                  (ride) => _buildAvailableRideCard(ride),
                ),

                const SizedBox(height: 12),

                // RECOMMENDED ROUTES

                _sectionHeader('Recommended Routes'),

                const SizedBox(height: 9),

                ...recommendedRoutes.map(
                  (route) => _buildRecommendedRoute(
                    route['route']!,
                    route['description']!,
                  ),
                ),

                const SizedBox(height: 10),

                // SAFETY BANNER

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
  // PLACEHOLDER FOR NEXT TABS
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
              onPressed: () {
                _changeTab(0);
              },

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
            children: List.generate(
              navItems.length,
              (index) {
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
                          Icon(
                            selected
                                ? item['activeIcon']
                                : item['icon'],

                            size: 21,

                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),

                          const SizedBox(height: 4),

                          Text(
                            item['title'],

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
              },
            ),
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
              : _buildComingSoon(),
),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
