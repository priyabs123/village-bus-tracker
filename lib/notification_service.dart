import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: settings,
    );
  }

  static Future<void> showBusNearbyNotification(String message) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'bus_nearby_channel',
      'Bus Nearby Alerts',
      channelDescription: 'Notifies when bus is nearby',
      importance: Importance.high,
      priority: Priority.high,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: 0,
      title: '🚌 Bus Alert!',
      body: message,
      notificationDetails: details,
    );
  }
}