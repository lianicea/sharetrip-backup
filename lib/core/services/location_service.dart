import 'package:geolocator/geolocator.dart';

/// One GPS implementation shared by student maps and driver trip tracking.
class LocationService {
  Future<void> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Turn on device location and retry.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied. Allow location access for ShareTrip.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is blocked. Enable it in browser or device settings.');
    }
    if (permission == LocationPermission.unableToDetermine) {
      throw Exception('The browser could not determine location permission. Check site permissions.');
    }
  }

  Future<Position> getCurrentLocation() async {
    await checkPermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      ),
    );
  }

  Stream<Position> getLocationStream() async* {
    await checkPermission();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 3,
      ),
    );
  }
}
