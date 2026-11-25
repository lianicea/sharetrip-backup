
import 'package:flutter/material.dart';
import '../find_ride/ride_map_page.dart';
import '../../../core/constants/app_colors.dart';

// ==========================================
// RIDE RECORD MODEL
// ==========================================

class MyRideRecord {
  final String id;
  final String driver;
  final String vehicle;
  final String plateNumber;
  final String route;
  final String departure;
  final String date;
  final int availableSeats;
  final double fare;
  final double rating;
  final String status;

  bool isCancelled;
  bool hasRated;
  double? studentRating;
  String feedback;

  MyRideRecord({
    required this.id,
    required this.driver,
    required this.vehicle,
    required this.plateNumber,
    required this.route,
    required this.departure,
    required this.date,
    required this.availableSeats,
    required this.fare,
    required this.rating,
    required this.status,
    this.isCancelled = false,
    this.hasRated = false,
    this.studentRating,
    this.feedback = '',
  });
}

// ==========================================
// MY RIDES PAGE
// ==========================================

class MyRidesPage extends StatefulWidget {
  const MyRidesPage({super.key});

  @override
  State<MyRidesPage> createState() => _MyRidesPageState();
}

class _MyRidesPageState extends State<MyRidesPage> {
  int selectedTab = 0;

  final List<String> tabs = [
    'Active',
    'Upcoming',
    'Completed',
  ];

  // ==========================================
  // DEMO RIDE RECORDS
  // ==========================================

  final List<MyRideRecord> rides = [
    MyRideRecord(
      id: 'RIDE-001',
      driver: 'Alex Santos',
      vehicle: 'Toyota Vios',
      plateNumber: 'ABC 1234',
      route: 'Bitin → CMDI Main Campus',
      departure: '6:30 AM',
      date: 'Today',
      availableSeats: 3,
      fare: 25,
      rating: 4.8,
      status: 'Active',
    ),
    MyRideRecord(
      id: 'RIDE-002',
      driver: 'Maria Reyes',
      vehicle: 'Honda Click 160',
      plateNumber: 'XYZ 5678',
      route: 'Maitim → CMDI Main Campus',
      departure: '7:00 AM',
      date: 'Tomorrow',
      availableSeats: 1,
      fare: 20,
      rating: 4.9,
      status: 'Upcoming',
    ),
    MyRideRecord(
      id: 'RIDE-003',
      driver: 'Carlo Mendoza',
      vehicle: 'School Shuttle',
      plateNumber: 'SH-204',
      route: 'Tranca → CMDI Main Campus',
      departure: '7:15 AM',
      date: 'November 17, 2026',
      availableSeats: 7,
      fare: 30,
      rating: 4.7,
      status: 'Completed',
    ),
  ];

  // ==========================================
  // FILTER RIDES
  // ==========================================

  List<MyRideRecord> get filteredRides {
    return rides.where((ride) {
      return ride.status == tabs[selectedTab] &&
          !ride.isCancelled;
    }).toList();
  }

  // ==========================================
  // SNACKBAR
  // ==========================================

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
  // TRACK RIDE
  // ==========================================

  void _trackRide(MyRideRecord ride) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RideMapPage(ride: ride),
      ),
    );
  }

  // ==========================================
  // RIDE DETAILS
  // ==========================================

  void _viewRideDetails(MyRideRecord ride) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Ride Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Ride ID', ride.id),
                _detailRow('Driver', ride.driver),
                _detailRow('Vehicle', ride.vehicle),
                _detailRow('Plate Number', ride.plateNumber),
                _detailRow('Route', ride.route),
                _detailRow('Date', ride.date),
                _detailRow('Departure', ride.departure),
                _detailRow(
                  'Available Seats',
                  '${ride.availableSeats}',
                ),
                _detailRow(
                  'Fare',
                  '₱${ride.fare.toStringAsFixed(2)}',
                ),
                _detailRow(
                  'Driver Rating',
                  '${ride.rating.toStringAsFixed(1)} ★',
                ),
                _detailRow('Status', ride.status),

                if (ride.hasRated) ...[
                  const Divider(height: 25),
                  const Text(
                    'YOUR RATING',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < (ride.studentRating ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: const Color(0xFFE5A72B),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ride.studentRating?.toStringAsFixed(1)} out of 5 stars',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'YOUR FEEDBACK',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F1FC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ride.feedback.isEmpty
                          ? 'No written feedback provided.'
                          : ride.feedback,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Text(
                  'Sample ride information only. Actual booking records will come from the backend.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // RATE DRIVER
  // ==========================================

  Future<void> _rateDriver(MyRideRecord ride) async {
    int selectedRating = 5;

    final TextEditingController feedbackController =
        TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Rate Your Driver',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EAFF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      ride.driver,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'How was your ride experience?',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // STAR RATING

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) {
                          return IconButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                            ),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              dialogSetState(() {
                                selectedRating = index + 1;
                              });
                            },
                            icon: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 35,
                              color: const Color(0xFFE5A72B),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      [
                        '',
                        'Poor',
                        'Fair',
                        'Good',
                        'Very Good',
                        'Excellent!',
                      ][selectedRating],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FEEDBACK

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Share your feedback',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: InputDecoration(
                        hintText:
                            'Tell us about your experience with the driver...',
                        hintStyle: const TextStyle(fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFFF5F4FA),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            {
                              'rating': selectedRating.toDouble(),
                              'feedback':
                                  feedbackController.text.trim(),
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    feedbackController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      ride.studentRating = result['rating'] as double;
      ride.feedback = result['feedback'] as String;
      ride.hasRated = true;
    });

    _showMessage('Thank you! Your rating has been submitted.');
  }

  // ==========================================
  // CANCEL RIDE
  // ==========================================

  Future<void> _cancelRide(MyRideRecord ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Cancel Ride?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel your ride with ${ride.driver}?',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Ride'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Ride'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        ride.isCancelled = true;
      });

      _showMessage('Demo ride cancelled successfully.');
    }
  }

  // ==========================================
  // HEADER
  // ==========================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 26),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(5),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Rides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Your active and past campus trips',
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
  // RIDE TABS
  // ==========================================

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final selected = selectedTab == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 3,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // RIDE STATUS BADGE
  // ==========================================

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case 'Active':
        color = AppColors.success;
        break;
      case 'Upcoming':
        color = AppColors.warning;
        break;
      default:
        color = const Color(0xFF168B70);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==========================================
  // RIDE INFORMATION BOX
  // ==========================================

  Widget _rideInfo(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1FC),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
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
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PRIMARY BUTTON
  // ==========================================

  Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 43,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(11),
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon ?? Icons.receipt_long_outlined,
            size: 16,
          ),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // OUTLINED BUTTON
  // ==========================================

  Widget _outlinedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 43,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // RIDE CARD
  // ==========================================

  Widget _buildRideCard(MyRideRecord ride) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DRIVER DETAILS

                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EAFF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        ride.vehicle.toLowerCase().contains('click')
                            ? Icons.two_wheeler
                            : ride.vehicle.toLowerCase().contains('shuttle')
                                ? Icons.airport_shuttle_outlined
                                : Icons.directions_car_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.driver,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ride.vehicle} · ${ride.plateNumber}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Color(0xFFE5A72B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ride.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC18A19),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // ROUTE

                Text(
                  ride.route,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  ride.date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 13),

                // STATUS

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RIDE STATUS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _statusBadge(ride.status),
                  ],
                ),

                const SizedBox(height: 13),

                // RIDE INFORMATION

                Row(
                  children: [
                    _rideInfo('DEPARTURE', ride.departure),
                    const SizedBox(width: 7),
                    _rideInfo(
                      'AVAILABLE',
                      '${ride.availableSeats} seats',
                    ),
                    const SizedBox(width: 7),
                    _rideInfo(
                      'FARE',
                      '₱${ride.fare.toStringAsFixed(0)}',
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ACTIVE RIDE

                if (ride.status == 'Active')
                  _primaryButton(
                    label: 'Track Ride',
                    icon: Icons.location_on_outlined,
                    onPressed: () => _trackRide(ride),
                  ),

                // UPCOMING RIDE

                if (ride.status == 'Upcoming') ...[
                  _primaryButton(
                    label: 'View Details',
                    icon: Icons.receipt_long_outlined,
                    onPressed: () => _viewRideDetails(ride),
                  ),
                  const SizedBox(height: 9),
                  SizedBox(
                    width: double.infinity,
                    height: 43,
                    child: ElevatedButton(
                      onPressed: () => _cancelRide(ride),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: const Text(
                        'Cancel Ride',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],

                // COMPLETED RIDE

                if (ride.status == 'Completed') ...[
                  _primaryButton(
                    label: 'View Ride Details',
                    icon: Icons.receipt_long_outlined,
                    onPressed: () => _viewRideDetails(ride),
                  ),

                  const SizedBox(height: 9),

                  if (!ride.hasRated)
                    SizedBox(
                      width: double.infinity,
                      height: 43,
                      child: OutlinedButton.icon(
                        onPressed: () => _rateDriver(ride),
                        icon: const Icon(
                          Icons.star_outline,
                          size: 18,
                        ),
                        label: const Text(
                          'Rate Driver & Feedback',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC18A19),
                          side: const BorderSide(
                            color: Color(0xFFE5A72B),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7F0),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 17,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Rating Submitted · ${ride.studentRating?.toStringAsFixed(1)} ★',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================

  Widget _buildEmptyState() {
    final messages = [
      'No other active rides',
      'No other upcoming rides',
      'No other completed rides',
    ];

    final descriptions = [
      'Your active rides will appear here automatically.',
      'Your scheduled rides will be organized here.',
      'Your previous campus trips will appear here.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 37,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1FC),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.alt_route,
              size: 26,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            messages[selectedTab],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            descriptions[selectedTab],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD PAGE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final displayedRides = filteredRides;

    return Column(
      children: [
        _buildHeader(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabs(),

                const SizedBox(height: 19),

                // RIDE COUNT

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${displayedRides.length} ${tabs[selectedTab]} Rides',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Icon(
                      Icons.directions_car_outlined,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // RIDE LIST

                if (displayedRides.isEmpty)
                  _buildEmptyState()
                else
                  ...displayedRides.map(
                    (ride) => _buildRideCard(ride),
                  ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    'ShareTrip · My Rides Demo',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
