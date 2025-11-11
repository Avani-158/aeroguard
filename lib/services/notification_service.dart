import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Get FCM token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Alert',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'iot_alerts',
          'IoT Alerts',
          channelDescription: 'Notifications for IoT device alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static void _handleBackgroundMessage(RemoteMessage message) {
    print('Background message: ${message.messageId}');
  }

  // Subscribe to device alerts
  static Future<void> subscribeToAlerts(String deviceId) async {
    await _messaging.subscribeToTopic('device_$deviceId');
    await _messaging.subscribeToTopic('fire_alerts');
    await _messaging.subscribeToTopic('aqi_alerts');
  }

  // Unsubscribe from alerts
  static Future<void> unsubscribeFromAlerts(String deviceId) async {
    await _messaging.unsubscribeFromTopic('device_$deviceId');
    await _messaging.unsubscribeFromTopic('fire_alerts');
    await _messaging.unsubscribeFromTopic('aqi_alerts');
  }
}


