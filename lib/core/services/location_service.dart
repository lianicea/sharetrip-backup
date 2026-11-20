
import 'package:geolocator/geolocator.dart';

class LocationService {
  // CHECK LOCATION PERMISSION
  Future<bool> checkPermission() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied.',
      );
    }

    return true;
  }

  // GET CURRENT GPS LOCATION
  Future<Position> getCurrentLocation() async {
    await checkPermission();

    try {
      const LocationSettings settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 20),
      );

      return await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );
    } catch (e) {
      throw Exception(
        'Unable to get current location: $e',
      );
    }
  }

  // LISTEN TO LOCATION CHANGES
  Stream<Position> getLocationStream() async* {
    await checkPermission();

    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    yield* Geolocator.getPositionStream(
      locationSettings: settings,
    );
  }
}
