// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

// Your local flat-directory file project imports
import 'splash_screen.dart';
import 'models/vault_item.dart';
import 'luxury_media_upload_screen.dart';
import 'notification_service.dart';
import 'app_status_provider.dart';
import 'provider_screen.dart';
import 'redux_store.dart';

/// Top-level background message handler for Firebase Cloud Messaging (FCM).
/// This MUST be a top-level function and annotated with @pragma('vm:entry-point')
/// so that it can run in an isolated background thread when the app is completely closed.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background push message: ${message.messageId}");
}

void main() async {
  // 1. Essential framework hook binding before async initialization tasks
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase app instance across native pipelines
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase Initialized: ${Firebase.app().options.projectId}");
  } catch (e) {
    debugPrint("❌ Firebase Initialization Failed: $e");
  }

  // 3. Register the Background Messaging Worker for push notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. Fire up the local notification manager channels and fetch device token
  try {
    await NotificationService.initialize();
    debugPrint("✅ Notification Services Initialized Successfully.");
  } catch (e) {
    debugPrint("❌ Notification Services Initialization Failed: $e");
  }

  // 5. Initialize Core Flutter Hive Architecture Extension
  await Hive.initFlutter();

  // 6. Open dedicated persistence box layer for luxury screen media studio files
  await Hive.openBox('luxury_studio_box');

  // 7. Fire up Hive local NoSQL database engine and load saved products from disk
  await VaultDataManager().initHiveAndLoadData();

  // Initialize Redux Store
  final store = createReduxStore();

  // 8. Run the Root Application Widget Tree Frame wrapped with your State Providers
  runApp(
    StoreProvider<ReduxState>(
      store: store,
      child: ChangeNotifierProvider(
        create: (context) => AppStatusProvider(),
        child: const BeautyStoreApp(),
      ),
    ),
  );
}

class BeautyStoreApp extends StatelessWidget {
  const BeautyStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Uses GetMaterialApp to wrap both global theme properties and GetX navigators concurrently
    return GetMaterialApp(
      title: 'GLOWHER',
      debugShowCheckedModeBanner: false,

      // CRITICAL LINK: Connects the notification routing system to your app lifecycle context
      navigatorKey: NotificationService.navigatorKey,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09060B),
        fontFamily: 'Serif',
      ),

      // Automatically launches your premium branding intro layout
      home: const SplashScreen(),
    );
  }
}