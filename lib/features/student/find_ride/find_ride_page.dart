
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

// ==========================================
// RIDE MODEL
// ==========================================

class RideListing {
  final String driverName;
  final String vehicle;
  final String vehicleType;
  final String plateNumber;
  final String pickup;
  final String destination;
  final String departure;
  final int availableSeats;
  final double fare;
  final double rating;

  const RideListing({
    required this.driverName,
    required this.vehicle,
    required this.vehicleType,
    required this.plateNumber,
    required this.pickup,
    required this.destination,
    required this.departure,
    required this.availableSeats,
    required this.fare,
    required this.rating,
  });

  String get route => '$pickup → $destination';
}

// ==========================================
// FIND A RIDE PAGE
// ==========================================

class FindRidePage extends StatefulWidget {
  const FindRidePage({super.key});

  @override
  State<FindRidePage> createState() => _FindRidePageState();
}

class _FindRidePageState extends State<FindRidePage> {
  final TextEditingController _searchController =
      TextEditingController();

  final TextEditingController _pickupController =
      TextEditingController();

  String selectedVehicle = 'All';
  String selectedSort = 'Recommended';

  // ==========================================
  // VEHICLE FILTERS
  // ==========================================

  final List<String> vehicleFilters = [
    'All',
    'Car',
    'Motorcycle',
    'Van',
    'Shuttle',
    'Tricycle',
  ];

  // ==========================================
  // DEMO AVAILABLE RIDES
  // ==========================================

  final List<RideListing> rides = const [
    RideListing(
      driverName: 'Alex Santos',
      vehicle: 'Toyota Vios',
      vehicleType: 'Car',
      plateNumber: 'ABC 1234',
      pickup: 'Bitin',
      destination: 'CMDI Main Campus',
      departure: '6:30 AM',
      availableSeats: 3,
      fare: 25,
      rating: 4.8,
    ),

    RideListing(
      driverName: 'Maria Reyes',
      vehicle: 'Honda Click 160',
      vehicleType: 'Motorcycle',
      plateNumber: 'XYZ 5678',
      pickup: 'Maitim',
      destination: 'CMDI Main Campus',
      departure: '7:00 AM',
      availableSeats: 1,
      fare: 20,
      rating: 4.9,
    ),

    RideListing(
      driverName: 'Carlo Mendoza',
      vehicle: 'School Shuttle',
      vehicleType: 'Shuttle',
      plateNumber: 'SH-204',
      pickup: 'Tranca',
      destination: 'CMDI Main Campus',
      departure: '7:15 AM',
      availableSeats: 7,
      fare: 30,
      rating: 4.7,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  // ==========================================
  // FILTER RIDES
  // ==========================================

  List<RideListing> get filteredRides {
    final search = _searchController.text
        .trim()
        .toLowerCase();

    final pickupSearch = _pickupController.text
        .trim()
        .toLowerCase();

    final result = rides.where((ride) {
      final matchesSearch =
          search.isEmpty ||
          ride.driverName.toLowerCase().contains(search) ||
          ride.vehicle.toLowerCase().contains(search) ||
          ride.route.toLowerCase().contains(search) ||
          ride.pickup.toLowerCase().contains(search) ||
          ride.destination.toLowerCase().contains(search);

      final matchesPickup =
          pickupSearch.isEmpty ||
          ride.pickup.toLowerCase().contains(pickupSearch);

      final matchesVehicle =
          selectedVehicle == 'All' ||
          ride.vehicleType == selectedVehicle;

      return matchesSearch &&
          matchesPickup &&
          matchesVehicle &&
          ride.availableSeats > 0;
    }).toList();

    // SORT OPTIONS

    if (selectedSort == 'Highest Rated') {
      result.sort(
        (a, b) => b.rating.compareTo(a.rating),
      );
    } else if (selectedSort == 'Lowest Fare') {
      result.sort(
        (a, b) => a.fare.compareTo(b.fare),
      );
    }

    return result;
  }

  // ==========================================
  // SNACKBAR
  // ==========================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        24,
        22,
        25,
      ),
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
            'Find a Ride',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Compare verified campus rides',
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
  // SEARCH INPUT
  // ==========================================

  Widget _buildSearchInput() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search destination or route...',
        hintStyle: const TextStyle(fontSize: 12),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 19,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 43,
          minHeight: 42,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.close,
                  size: 17,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PICKUP INPUT
  // ==========================================

  Widget _buildPickupInput() {
    return TextField(
      controller: _pickupController,
      onChanged: (_) {
        setState(() {});
      },
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Pickup point',
        hintStyle: const TextStyle(fontSize: 12),
        prefixIcon: const Icon(
          Icons.location_on_outlined,
          color: AppColors.textSecondary,
          size: 19,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 43,
          minHeight: 42,
        ),
        suffixIcon: _pickupController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _pickupController.clear();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.close,
                  size: 17,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CURRENT LOCATION BUTTON
  // ==========================================

  Widget _buildCurrentLocationButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          _showMessage(
            'GPS and location permissions will be connected in the Maps phase.',
          );
        },
        icon: const Icon(
          Icons.my_location,
          size: 16,
          color: AppColors.primary,
        ),
        label: const Text(
          'Use My Current Location',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 5,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VEHICLE FILTER CHIPS
  // ==========================================

  Widget _buildVehicleFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: vehicleFilters.map((vehicle) {
          final selected = selectedVehicle == vehicle;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(vehicle),
              selected: selected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : AppColors.border,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              onSelected: (_) {
                setState(() {
                  selectedVehicle = vehicle;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // MORE FILTERS / SORTING
  // ==========================================

  Future<void> _showMoreFilters() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        final options = [
          'Recommended',
          'Highest Rated',
          'Lowest Fare',
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'More Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose how you want to sort available rides.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'SORT BY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                ...options.map((option) {
                  return RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: Text(
                      option,
                      style: const TextStyle(fontSize: 13),
                    ),
                    value: option,
                    groupValue: selectedSort,
                    onChanged: (value) {
                      Navigator.pop(sheetContext, value);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        selectedSort = result;
      });
    }
  }

  // ==========================================
  // SECTION HEADER
  // ==========================================

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'More filters',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        TextButton.icon(
          onPressed: _showMoreFilters,
          icon: const Icon(
            Icons.tune,
            size: 16,
          ),
          label: Text(
            selectedSort,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // RIDE INFORMATION BOX
  // ==========================================

  Widget _rideInfoBox(
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1FC),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // REQUEST RIDE
  // ==========================================

  Future<void> _requestRide(RideListing ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Request Ride',
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
                ride.driverName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                ride.vehicle,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                ride.route,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _dialogDetail('Departure', ride.departure),
              _dialogDetail('Available Seats', '${ride.availableSeats}'),
              _dialogDetail('Fare', '₱${ride.fare.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              const Text(
                'Demo only. No actual booking request will be sent to the driver yet.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  height: 1.5,
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
              child: const Text('Confirm Request'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _showMessage(
        'Demo request confirmed. Driver notification is not connected yet.',
      );
    }
  }

  Widget _dialogDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // AVAILABLE RIDE CARD
  // ==========================================

  Widget _buildRideCard(RideListing ride) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
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
                // DRIVER DETAILS

                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EAFF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        ride.vehicleType == 'Motorcycle'
                            ? Icons.two_wheeler
                            : ride.vehicleType == 'Shuttle'
                                ? Icons.airport_shuttle_outlined
                                : Icons.directions_car_outlined,
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
                            ride.driverName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${ride.vehicle} · ${ride.plateNumber}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.star,
                      size: 17,
                      color: Color(0xFFE3A42B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ride.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC18B1C),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ROUTE

                Row(
                  children: [
                    const Icon(
                      Icons.alt_route,
                      size: 17,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        ride.route,
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

                // RIDE DETAILS

                Row(
                  children: [
                    Expanded(
                      child: _rideInfoBox(
                        'DEPARTURE',
                        ride.departure,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _rideInfoBox(
                        'AVAILABLE',
                        '${ride.availableSeats} seats',
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _rideInfoBox(
                        'FARE',
                        '₱${ride.fare.toStringAsFixed(0)}',
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

  // ==========================================
  // EMPTY STATE
  // ==========================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 43,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'No rides found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try changing your route, pickup point, or filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CLEAR FILTERS
  // ==========================================

  void _clearFilters() {
    _searchController.clear();
    _pickupController.clear();

    setState(() {
      selectedVehicle = 'All';
      selectedSort = 'Recommended';
    });
  }

  // ==========================================
  // BUILD PAGE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final results = filteredRides;

    return Column(
      children: [
        _buildHeader(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              19,
              18,
              19,
              25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SEARCH DESTINATION

                _buildSearchInput(),

                const SizedBox(height: 12),

                // PICKUP POINT

                _buildPickupInput(),

                const SizedBox(height: 5),

                // GPS BUTTON

                _buildCurrentLocationButton(),

                const SizedBox(height: 13),

                // VEHICLE FILTERS

                _buildVehicleFilters(),

                const SizedBox(height: 10),

                // MORE FILTERS

                _buildSectionHeader(),

                const SizedBox(height: 11),

                // RESULTS COUNT

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${results.length} available rides',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    if (selectedVehicle != 'All' ||
                        searchQueryIsActive)
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text(
                          'Clear filters',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // RIDE LIST

                if (results.isEmpty)
                  _buildEmptyState()
                else
                  ...results.map(
                    (ride) => _buildRideCard(ride),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool get searchQueryIsActive =>
      _searchController.text.isNotEmpty ||
      _pickupController.text.isNotEmpty ||
      selectedSort != 'Recommended';
}
