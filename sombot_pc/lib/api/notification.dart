import 'dart:io' show Platform;

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
    // Request permissions (iOS/macOS and web handled by Firebase)
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print(
          '🔔 Notification permission status: ${settings.authorizationStatus}');

      // On Android 13+ the app needs POST_NOTIFICATIONS runtime permission.
      // flutter_local_notifications exposes a helper to request that when available.
      if (Platform.isAndroid) {
        // On Android 13+ (API 33+) the app must request POST_NOTIFICATIONS at runtime.
        // The local notifications plugin doesn't expose a stable cross-version
        // request API in all releases; consider using `permission_handler` or
        // platform channels to request `POST_NOTIFICATIONS` if targeting Android 13+.
        print(
            'ℹ️ Reminder: on Android 13+ request POST_NOTIFICATIONS runtime permission.');
      }

      // Token (only fetch if we at least have provisional/authorized)
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional ||
          Platform.isAndroid) {
        final token = await _firebaseMessaging.getToken();
        print('✅ FCM Token: $token');
      } else {
        print('ℹ️ Notifications not authorized by the user.');
      }
    } catch (e) {
      print('Error while requesting notification permission: $e');
    }

    // iOS Foreground Notification Config
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local Notification Channel (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
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
