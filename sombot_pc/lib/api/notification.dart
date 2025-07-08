import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> getToken() async {
    final token = await _firebaseMessaging.getToken();
    print('✅ FCM Token: $token');
  }
  Future<void> init() async {
    // Request permissions
    //NotificationSettings settings = await _firebaseMessaging.requestPermission();

    // Token
    final token = await _firebaseMessaging.getToken();
    print('✅ FCM Token: $token');

    // iOS Foreground Notification Config
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local Notification Channel (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notifications',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message received: ${message.notification?.title}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              importance: Importance.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }
}
