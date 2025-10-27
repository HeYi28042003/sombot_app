import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission(); // Important for iOS

    // Optionally: listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📲 Foreground message: ${message.notification?.title}');
    });
  }

  Future<String?> getToken() async {
    String? apnsToken;

    // Wait until APNS token is set (for iOS)
    while (apnsToken == null) {
      apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    final fcmToken = await _messaging.getToken();
    print('📬 FCM Token: $fcmToken');
    return fcmToken;
  }
}
