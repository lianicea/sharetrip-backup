import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  Future<void> initialize(Future<void> Function(String token) saveToken) async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken();
    if (token != null) await saveToken(token);
    messaging.onTokenRefresh.listen(saveToken);
  }
}
