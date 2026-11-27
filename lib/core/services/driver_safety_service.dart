import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';

class DriverSafetyService {
  static const _contactKey = 'driver_emergency_contact';
  final LocationService location = LocationService();

  Future<String> getEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_contactKey) ?? '';
  }

  Future<void> saveEmergencyContact(String contact) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contactKey, contact.trim());
  }

  /// Opens the device SMS composer with an SOS message and current coordinates.
  /// The driver must review and press Send; the app cannot silently dispatch SMS.
  Future<bool> composeSos({required String contact}) async {
    final position = await location.getCurrentLocation();
    final message = Uri.encodeComponent(
      'SHARETRIP DRIVER SOS: I need assistance. '
      'My current location: https://maps.google.com/?q=${position.latitude},${position.longitude} '
      '(Accuracy: ${position.accuracy.toStringAsFixed(0)} m).',
    );
    final uri = Uri(scheme: 'sms', path: contact, queryParameters: {'body': Uri.decodeComponent(message)});
    return launchUrl(uri);
  }

  Future<bool> callEmergencyServices() async {
    return launchUrl(Uri(scheme: 'tel', path: '911'));
  }
}
