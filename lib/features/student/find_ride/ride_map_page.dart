
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  // DEMO COORDINATES
  // Replace these with actual ride coordinates when available.
  final LatLng _pickupLocation = const LatLng(14.1775, 121.2830);
  final LatLng _destinationLocation = const LatLng(14.1765, 121.2870);

  LatLng? _currentLocation;

  List<LatLng> _routePoints = [];

  StreamSubscription<Position>? _positionSubscription;

  bool _isLoadingLocation = true;
  bool _isRouteLoading = true;
  bool _mapReady = false;
  bool _followLocation = true;
  bool _isFetchingRoute = false;
  bool _hasArrived = false;

  String? _locationError;
  String? _routeError;

  double? _distanceKm;
  double? _durationMinutes;

  double _heading = 0;

  LatLng? _lastRouteRequestLocation;
  DateTime? _lastRouteRequestTime;

  static const double _rerouteDistanceMeters = 50;
  static const double _arrivalDistanceMeters = 30;

  @override
  void initState() {
    super.initState();

    _loadRoadRoute(
      _pickupLocation,
      _destinationLocation,
    );

    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  // --------------------------------------------------
  // LOAD ROAD ROUTE USING OSRM
  // --------------------------------------------------

  Future<void> _loadRoadRoute(
    LatLng start,
    LatLng destination, {
    bool force = false,
  }) async {
    if (!mounted || _isFetchingRoute) return;

    if (!force && _lastRouteRequestLocation != null) {
      final double movedDistance = const Distance().as(
        LengthUnit.Meter,
        _lastRouteRequestLocation!,
        start,
      );

      final DateTime now = DateTime.now();

      final bool movedEnough =
          movedDistance >= _rerouteDistanceMeters;

      final bool timePassed = _lastRouteRequestTime == null ||
          now.difference(_lastRouteRequestTime!).inSeconds >= 20;

      if (!movedEnough && !timePassed) return;
    }

    _isFetchingRoute = true;

    if (mounted) {
      setState(() {
        _isRouteLoading = true;
        _routeError = null;
      });
    }

    try {
      final String coordinates =
          '${start.longitude},${start.latitude};'
          '${destination.longitude},${destination.latitude}';

      final Uri url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$coordinates?overview=full&geometries=geojson',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Unable to get route from server.');
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (data['code'] != 'Ok' ||
          data['routes'] == null ||
          (data['routes'] as List).isEmpty) {
        throw Exception('No road route found.');
      }

      final Map<String, dynamic> route =
          data['routes'][0] as Map<String, dynamic>;

      final List coordinatesList =
          route['geometry']['coordinates'] as List;

      final List<LatLng> points = coordinatesList.map((point) {
        return LatLng(
          (point[1] as num).toDouble(),
          (point[0] as num).toDouble(),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _routePoints = points;

        _distanceKm =
            (route['distance'] as num).toDouble() / 1000;

        _durationMinutes =
            (route['duration'] as num).toDouble() / 60;

        _isRouteLoading = false;
        _routeError = null;

        _lastRouteRequestLocation = start;
        _lastRouteRequestTime = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _routeError = 'Unable to update road route.';
        _isRouteLoading = false;
      });
    } finally {
      _isFetchingRoute = false;
    }
  }

  // --------------------------------------------------
  // START LIVE GPS TRACKING
  // --------------------------------------------------

  Future<void> _startLocationTracking() async {
    try {
      final Position position =
          await _locationService.getCurrentLocation();

      if (!mounted) return;

      final LatLng location = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentLocation = location;
        _heading = position.heading;
        _isLoadingLocation = false;
        _locationError = null;
      });

      _moveToCurrentLocation();

      // Get a live route from the current location
      // to the destination.
      await _loadRoadRoute(
        location,
        _destinationLocation,
        force: true,
      );

      if (!mounted) return;

      await _positionSubscription?.cancel();

      _positionSubscription =
          _locationService.getLocationStream().listen(
        (Position position) {
          if (!mounted) return;

          final LatLng newLocation = LatLng(
            position.latitude,
            position.longitude,
          );

          final double distanceToDestination =
              const Distance().as(
            LengthUnit.Meter,
            newLocation,
            _destinationLocation,
          );

          setState(() {
            _currentLocation = newLocation;
            _heading = position.heading;

            _isLoadingLocation = false;
            _locationError = null;

            _hasArrived =
                distanceToDestination <= _arrivalDistanceMeters;
          });

          // Automatically follow the user's GPS location.
          if (_followLocation) {
            _moveToCurrentLocation();
          }

          // Update route when the user moves far enough.
          if (!_hasArrived) {
            _loadRoadRoute(
              newLocation,
              _destinationLocation,
            );
          }
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _locationError = error.toString();
            _isLoadingLocation = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
      });
    }
  }

  // --------------------------------------------------
  // MAP CAMERA
  // --------------------------------------------------

  void _moveToCurrentLocation() {
    if (!_mapReady || _currentLocation == null) return;

    _mapController.move(
      _currentLocation!,
      17,
    );
  }

  void _recenterMap() {
    if (_currentLocation == null) return;

    setState(() {
      _followLocation = true;
    });

    _moveToCurrentLocation();
  }

  // --------------------------------------------------
  // MARKERS
  // --------------------------------------------------

  Marker _buildMarker({
    required LatLng point,
    required Widget child,
    double width = 45,
    double height = 55,
  }) {
    return Marker(
      point: point,
      width: width,
      height: height,
      child: child,
    );
  }

  Widget _buildCurrentLocationMarker() {
    return Transform.rotate(
      angle: _heading * (3.141592653589793 / 180),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.withValues(alpha: 0.18),
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.navigation,
              color: Colors.white,
              size: 10,
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // BUILD SCREEN
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Live Ride Navigation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _pickupLocation,
                    initialZoom: 15,
                    onMapReady: () {
                      _mapReady = true;

                      if (_currentLocation != null) {
                        _moveToCurrentLocation();
                      }
                    },
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture && _followLocation) {
                        setState(() {
                          _followLocation = false;
                        });
                      }
                    },
                  ),
                  children: [
                    // MAP TILES
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sharetrip.app',
                    ),

                    // ROAD ROUTE
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 6,
                            color: AppColors.primary,
                            borderStrokeWidth: 2,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),

                    // MAP MARKERS
                    MarkerLayer(
                      markers: [
                        // PICKUP
                        _buildMarker(
                          point: _pickupLocation,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 42,
                          ),
                        ),

                        // DESTINATION
                        _buildMarker(
                          point: _destinationLocation,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 42,
                          ),
                        ),

                        // LIVE GPS LOCATION
                        if (_currentLocation != null)
                          _buildMarker(
                            point: _currentLocation!,
                            width: 38,
                            height: 38,
                            child: _buildCurrentLocationMarker(),
                          ),
                      ],
                    ),

                    // MAP ATTRIBUTION
                    const RichAttributionWidget(
                      attributions: const [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                        ),
                      ],
                    ),
                  ],
                ),

                // NAVIGATION INFORMATION
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: _buildNavigationStatus(),
                ),

                // GPS LOADING
                if (_isLoadingLocation)
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _statusCard(
                      icon: Icons.gps_fixed,
                      message: 'Getting GPS location...',
                    ),
                  ),

                // GPS ERROR
                if (_locationError != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _statusCard(
                      icon: Icons.location_disabled,
                      message: 'GPS unavailable. Check location permission.',
                    ),
                  ),

                // RECENTER BUTTON
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    onPressed: _recenterMap,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),

          // RIDE INFORMATION
          _buildRideInformation(),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // NAVIGATION STATUS CARD
  // --------------------------------------------------

  Widget _buildNavigationStatus() {
    String statusMessage;

    IconData statusIcon;

    if (_hasArrived) {
      statusMessage = 'You have arrived at your destination!';
      statusIcon = Icons.flag;
    } else if (_isLoadingLocation) {
      statusMessage = 'Connecting to GPS...';
      statusIcon = Icons.gps_fixed;
    } else if (_isRouteLoading) {
      statusMessage = 'Updating navigation route...';
      statusIcon = Icons.route;
    } else if (_locationError != null) {
      statusMessage = 'Waiting for GPS location...';
      statusIcon = Icons.location_disabled;
    } else {
      statusMessage = 'Live navigation is active';
      statusIcon = Icons.navigation;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: _hasArrived
                  ? Colors.green
                  : AppColors.primary,
              size: 25,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                statusMessage,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            if (_isRouteLoading && !_hasArrived)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // STATUS CARD
  // --------------------------------------------------

  Widget _statusCard({
    required IconData icon,
    required String message,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // RIDE INFORMATION PANEL
  // --------------------------------------------------

  Widget _buildRideInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ride Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _infoRow(
            Icons.person,
            'Driver',
            widget.ride.driver,
          ),

          _infoRow(
            Icons.directions_car,
            'Vehicle',
            widget.ride.vehicle,
          ),

          _infoRow(
            Icons.confirmation_number,
            'Plate Number',
            widget.ride.plateNumber,
          ),

          _infoRow(
            Icons.route,
            'Route',
            widget.ride.route,
          ),

          _infoRow(
            Icons.access_time,
            'Departure',
            widget.ride.departure,
          ),

          const Divider(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Remaining Distance',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _distanceKm == null
                    ? '--'
                    : '${_distanceKm!.toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Time Remaining',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _durationMinutes == null
                    ? '--'
                    : '${_durationMinutes!.round()} minutes',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (_routeError != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Unable to update route. Check your internet connection.',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final LatLng start =
                        _currentLocation ?? _pickupLocation;

                    _loadRoadRoute(
                      start,
                      _destinationLocation,
                      force: true,
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],

          if (_hasArrived) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Destination reached!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------
  // INFORMATION ROW
  // --------------------------------------------------

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
