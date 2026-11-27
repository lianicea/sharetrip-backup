import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../core/services/location_service.dart';
import '../../core/services/backend_service.dart';

/// Driver navigation to the live location shared by a student waiting for pickup.
/// Access is enforced by Supabase RLS for the accepted/pending ride request.
class DriverPickupNavigationPage extends StatefulWidget {
  final String studentId;
  final String rideId;
  final String studentName;
  const DriverPickupNavigationPage({super.key, required this.studentId,
    required this.rideId, required this.studentName});

  @override
  State<DriverPickupNavigationPage> createState() => _DriverPickupNavigationPageState();
}

class _DriverPickupNavigationPageState extends State<DriverPickupNavigationPage> {
  final _map = MapController();
  final _location = LocationService();
  StreamSubscription<Position>? _gpsSub;
  StreamSubscription<List<Map<String,dynamic>>>? _studentSub;
  Position? _driver;
  LatLng? _student;
  List<LatLng> _route = [];
  double? _km, _minutes;
  String? _error;
  bool _tracking = false, _routeBusy = false, _mapReady = false;

  @override void initState() { super.initState(); _watchStudent(); _startGps(); }
  void _watchStudent() {
    try {
      _studentSub = BackendService.instance.watchStudentLocation(widget.studentId, widget.rideId).listen((rows) {
        if (rows.isEmpty) return;
        final row = rows.first;
        final point = LatLng((row['latitude'] as num).toDouble(), (row['longitude'] as num).toDouble());
        if (!mounted) return;
        setState(() => _student = point);
        if (_driver != null) _loadRoute(LatLng(_driver!.latitude, _driver!.longitude), point);
      }, onError: (e) { if (mounted) setState(() => _error = 'Cannot read student location: $e'); });
    } catch (e) { _error = 'Backend not initialized. Configure Supabase first.'; }
  }
  Future<void> _startGps() async {
    try {
      final p = await _location.getCurrentLocation();
      if (!mounted) return;
      setState(() { _driver = p; _tracking = true; });
      await BackendService.instance.upsertDriverLocation(
        latitude: p.latitude, longitude: p.longitude, accuracy: p.accuracy,
        activeRideId: widget.rideId,
      );
      if (_student != null) _loadRoute(LatLng(p.latitude,p.longitude), _student!);
      _gpsSub = _location.getLocationStream().listen((p) {
        if (!mounted) return;
        setState(() => _driver = p);
        BackendService.instance.upsertDriverLocation(
          latitude: p.latitude, longitude: p.longitude, accuracy: p.accuracy,
          activeRideId: widget.rideId,
        ).catchError((e) {
          if (mounted) setState(() => _error = 'Could not publish driver GPS: $e');
        });
        if (_student != null) _loadRoute(LatLng(p.latitude,p.longitude), _student!);
      }, onError: (e) { if (mounted) setState(() => _error = 'Driver GPS error: $e'); });
    } catch (e) { if (mounted) setState(() => _error = 'Enable location permission: $e'); }
  }
  Future<void> _loadRoute(LatLng from, LatLng to) async {
    if (_routeBusy) return; _routeBusy = true;
    try {
      final uri = Uri.parse('https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=geojson');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body) as Map<String,dynamic>;
      if (res.statusCode != 200 || data['code'] != 'Ok' || (data['routes'] as List).isEmpty) throw Exception('No road route found');
      final r = (data['routes'] as List).first as Map<String,dynamic>;
      final points = ((r['geometry']['coordinates'] as List).map((p) => LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble()))).toList();
      if (!mounted) return;
      setState(() { _route = points; _km = (r['distance'] as num).toDouble()/1000; _minutes = (r['duration'] as num).toDouble()/60; _error = null; });
      if (_mapReady && points.isNotEmpty) _map.fitCamera(CameraFit.coordinates(coordinates: [from,to], padding: const EdgeInsets.all(65)));
    } catch (e) { if (mounted) setState(() => _error = 'Route unavailable: $e'); }
    finally { _routeBusy = false; }
  }
  @override void dispose() { _gpsSub?.cancel(); _studentSub?.cancel(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final driverPoint = _driver == null ? null : LatLng(_driver!.latitude,_driver!.longitude);
    return Scaffold(appBar: AppBar(title: const Text('Navigate to Student')),
      body: Column(children: [
        Expanded(child: FlutterMap(mapController: _map, options: MapOptions(
          initialCenter: driverPoint ?? const LatLng(14.18,121.28), initialZoom: 15,
          onMapReady: () { _mapReady = true; if (driverPoint != null && _student != null) _map.fitCamera(CameraFit.coordinates(coordinates: [driverPoint,_student!],padding: const EdgeInsets.all(60))); },
        ), children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.sharetrip.app'),
          if (_route.isNotEmpty) PolylineLayer(polylines: [Polyline(points: _route,color: Colors.deepPurple,strokeWidth: 6)]),
          MarkerLayer(markers: [
            if (driverPoint != null) Marker(point: driverPoint,width: 48,height: 48,child: const Icon(Icons.navigation,color: Colors.blue,size: 38)),
            if (_student != null) Marker(point: _student!,width: 48,height: 48,child: const Icon(Icons.person_pin_circle,color: Colors.red,size: 44)),
          ]),
        ])),
        SafeArea(top:false, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pickup: ${widget.studentName}',style: const TextStyle(fontSize:18,fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(_student == null ? 'Waiting for student to share live pickup location…' : '${_km?.toStringAsFixed(2) ?? '—'} km · ${_minutes?.round() ?? '—'} min to student'),
          if (_student != null) Text('Student GPS: ${_student!.latitude.toStringAsFixed(6)}, ${_student!.longitude.toStringAsFixed(6)}'),
          if (_error != null) Text(_error!,style: const TextStyle(color:Colors.red)),
          const SizedBox(height: 8),
          const Text('The student must enable pickup-location sharing in their ride screen. Location is visible only to the assigned driver under database policies.',style: TextStyle(fontSize:12)),
        ]))),
      ]));
  }
}
