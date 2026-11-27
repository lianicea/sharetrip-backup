import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Device-local alerts. Remote/push delivery requires a server and push provider.
class DriverNotificationService {
  DriverNotificationService._();
  static final DriverNotificationService instance = DriverNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialize() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> show(String title, String body, {int id = 0}) async {
    await initialize();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'sharetrip_driver_alerts',
        'Driver alerts',
        channelDescription: 'Ride requests, trip updates, and safety alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }
}
