// lib/notification_service.dart

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'maison_maps_screen.dart'; // Ensure this import matches your exact file path

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Global key to access the app navigator context safely from outside the widget tree
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    // 1. Explicitly request permission for Android 13+ / iOS
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Grab device token for background messaging debugging
    String? token = await _messaging.getToken();
    debugPrint("====== FIREBASE DEVICE TOKEN ======");
    debugPrint(token);
    debugPrint("====================================");

    // 3. Android initialization settings pointing to your exact manifest app icon
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped with payload: ${response.payload}");

        // Execute the navigation route jump cleanly if the payload instructs it
        if (response.payload == 'navigate_to_map') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const MaisonMapsScreen()),
          );
        }
      },
    );

    // 4. Handle incoming notification presentation when app is running in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Extract optional payload mapping if sent from Firebase Console custom data
        String clickAction = message.data['click_action'] ?? 'navigate_to_map';

        showLocalNotification(
          title: message.notification!.title ?? "Glowher Update",
          body: message.notification!.body ?? "",
          payload: clickAction,
        );
      }
    });
  }

  /// Trigger a 100% local, plain app notification banner instantly
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String payload = 'navigate_to_map', // Default fallback payload string
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'glowher_channel_id', // Aligns perfectly with AndroidManifest metadata configuration
      'Glowher Alerts',
      channelDescription: 'Main local communication channel for Glowher application updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // Use a unique epoch-based integer ID to avoid overriding ongoing notifications
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
      payload: payload, // Passes the payload down to the click event processor
    );
  }
}