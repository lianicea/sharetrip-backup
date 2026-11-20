
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../my_rides/my_rides_page.dart';

class RideMapPage extends StatefulWidget {
  final MyRideRecord ride;

  const RideMapPage({
    super.key,
    required this.ride,
  });

  @override
  State<RideMapPage> createState() => _RideMapPageState();
}

class _RideMapPageState extends State<RideMapPage> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _positionSubscription;

  Position? _currentPosition;

  bool _isLoading = true;
  bool _mapReady = false;

  String? _errorMessage;

  // DEMO COORDINATES
  static const LatLng pickupLocation =
      LatLng(14.1775, 121.2830);

  static const LatLng destinationLocation =
      LatLng(14.1765, 121.2870);

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  // START GPS TRACKING
  Future<void> _startLocationTracking() async {
    try {
      final stream = _locationService.getLocationStream();

      _positionSubscription = stream.listen(
        (Position position) {
          if (!mounted) return;

          setState(() {
            _currentPosition = position;
            _isLoading = false;
            _errorMessage = null;
          });

          _updateMapPosition();
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
            _errorMessage = error.toString();
          });
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // UPDATE MAP CENTER
  void _updateMapPosition() {
    if (!_mapReady || _currentPosition == null) return;

    final location = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    _mapController.move(location, 16);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your campus ride route',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.map_outlined,
                    color: Colors.white,
                    size: 25,
                  ),
                ],
              ),
            ),

            // MAP
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: pickupLocation,
                  initialZoom: 15,
                  onMapReady: () {
                    _mapReady = true;
                    _updateMapPosition();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.sharetrip.student',
                  ),

                  // SAMPLE ROUTE
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          pickupLocation,
                          destinationLocation,
                        ],
                        strokeWidth: 5,
                        color: AppColors.primary,
                      ),
                    ],
                  ),

                  // MAP MARKERS
                  MarkerLayer(
                    markers: [
                      // PICKUP
                      Marker(
                        point: pickupLocation,
                        width: 110,
                        height: 65,
                        child: const Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 38,
                            ),
                            Text(
                              'Pickup',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // DESTINATION
                      Marker(
                        point: destinationLocation,
                        width: 110,
                        height: 65,
                        child: const Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 38,
                            ),
                            Text(
                              'Destination',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // STUDENT CURRENT LOCATION
                      if (_currentPosition != null)
                        Marker(
                          point: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          width: 55,
                          height: 55,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // RIDE INFORMATION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RIDE INFORMATION',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFF0EAFF),
                        child: Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ride.driver,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${widget.ride.vehicle} · ${widget.ride.plateNumber}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${widget.ride.fare.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 25),

                  // GPS STATUS
                  Row(
                    children: [
                      Icon(
                        _currentPosition != null
                            ? Icons.gps_fixed
                            : Icons.gps_not_fixed,
                        color: _currentPosition != null
                            ? Colors.green
                            : Colors.orange,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isLoading
                              ? 'Getting your location...'
                              : _currentPosition != null
                                  ? 'GPS Connected'
                                  : 'GPS Unavailable',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _currentPosition != null
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),

                  if (_currentPosition != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                      ),
                    ),
                  ],

                  const Divider(height: 25),

                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 12,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          widget.ride.route,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Student GPS location is displayed using your browser location permission. Driver tracking will be connected in a later phase.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.5,
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
}
