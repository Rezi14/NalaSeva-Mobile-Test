import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../router/app_router.dart';
import '../../features/auth/logic/auth_provider.dart';
import '../../features/payment/logic/payment_provider.dart';
import '../../features/patient/logic/patient_provider.dart';
import '../../features/pharmacy/logic/pharmacy_provider.dart';
import '../../features/doctor/logic/doctor_provider.dart';
import '../theme/app_theme.dart';
import '../../features/auth/data/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Handling a background message: ${message.messageId}');
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AuthRepository _authRepository;

  FirebaseMessagingService(this._authRepository);

  void _handleMessageData(Map<String, dynamic> data) {
    try {
      log('Processing FCM Message Data: $data');
      final type = data['type']?.toString();
      final status = data['status']?.toString();
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        // Handle by 'type' field (from backend notifications)
        if (type == 'payment_updated' || type == 'payment') {
          context.read<PaymentProvider>().fetchMyPayments();
          context.read<PatientProvider>().fetchMyQueues();
        } else if (type == 'queue_updated' || type == 'queue') {
          context.read<PatientProvider>().fetchMyQueues();
          context.read<DoctorProvider>().fetchMyQueues();
        } else if (type == 'prescription_updated' || type == 'prescription') {
          context.read<PharmacyProvider>().fetchPharmacyQueues();
        }
        // Handle by 'status' field (older backend payload format)
        else if (status != null && (status == 'examining' || status == 'waiting' || status == 'completed' || status == 'cancelled')) {
          context.read<PatientProvider>().fetchMyQueues();
          context.read<DoctorProvider>().fetchMyQueues();
        }
      }
    } catch (e) {
      log('Error handling message data: $e');
    }
  }

  /// Navigate to the appropriate screen based on notification data.
  void _navigateFromNotification(Map<String, dynamic> data) {
    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context == null) return;

      final type = data['type']?.toString();
      final status = data['status']?.toString();

      String? route;

      if (type == 'payment_updated' || type == 'payment') {
        route = '/payment/list';
      } else if (type == 'prescription_updated' || type == 'prescription') {
        route = '/pharmacy/home';
      } else if (type == 'queue_updated' || type == 'queue' ||
          (status != null && ['examining', 'waiting', 'completed', 'cancelled'].contains(status))) {
        // Determine route based on user role
        try {
          final userRole = context.read<AuthProvider>().user?.role ?? '';
          if (userRole == 'doctor') {
            route = '/doctor/home';
          } else if (userRole == 'pharmacist') {
            route = '/pharmacy/home';
          } else {
            // patient or unknown
            route = '/patient/notifications';
          }
        } catch (_) {
          route = '/patient/notifications';
        }
      }

      if (route != null) {
        log('Navigating to: $route from notification tap');
        AppRouter.navigatorKey.currentState?.pushNamed(route);
      }
    } catch (e) {
      log('Error navigating from notification: $e');
    }
  }

  Future<void> initialize() async {
    log('Initializing FirebaseMessagingService...');
    
    // 1. Request Android local notification permissions first (runs independently of Firebase)
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      log('Requesting Android local notifications permission...');
      final bool? androidGranted = await androidImplementation?.requestNotificationsPermission();
      log('Android local notification permission request finished. Result: $androidGranted');
    } catch (e, stack) {
      log('Error requesting Android local notification permission: $e', error: e, stackTrace: stack);
    }

    // 2. Setup local notifications
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      log('Calling _localNotificationsPlugin.initialize...');
      await _localNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          log('Notification clicked: ${details.payload}');
          if (details.payload != null) {
            try {
              final data = jsonDecode(details.payload!);
              if (data is Map<String, dynamic>) {
                _handleMessageData(data);
                _navigateFromNotification(data);
              }
            } catch (e) {
              log('Error parsing notification click payload: $e');
            }
          }
        },
      );
      log('Local notifications plugin initialized successfully.');
    } catch (e, stack) {
      log('Error initializing local notifications plugin: $e', error: e, stackTrace: stack);
    }

    // 3. Setup Firebase Messaging (isolated to prevent crashes if Firebase is uninitialized)
    try {
      log('Setting up onBackgroundMessage...');
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      log('Background message handler configured.');

      log('Requesting Firebase messaging permission...');
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      log('Firebase notification authorizationStatus: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('Firebase notification permission granted');
      }

      // 4. Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Got a message whilst in the foreground!');
        log('Message data: ${message.data}');

        _handleMessageData(message.data);

        if (message.notification != null) {
          log('Message also contained a notification: ${message.notification}');
          showLocalNotification(message);
        }
      });

      // 5. Handle notification tap when app is in background (not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('Notification opened from background: ${message.data}');
        _handleMessageData(message.data);
        _navigateFromNotification(message.data);
      });

      // 6. Handle notification tap when app was terminated
      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        log('App opened from terminated via notification: ${initialMessage.data}');
        // Delay to ensure Navigator is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleMessageData(initialMessage.data);
          _navigateFromNotification(initialMessage.data);
        });
      }

      // 7. Listen to token refreshes and sync to backend
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        log('FCM Token refreshed: $newToken');
        try {
          const storage = FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );
          final hasToken = await storage.read(key: 'access_token');
          if (hasToken != null) {
            await _authRepository.updateFcmToken(newToken);
            log('Refreshed FCM Token successfully updated on backend.');
          }
        } catch (e) {
          log('Failed to update refreshed FCM Token on backend: $e');
        }
      });
    } catch (e, stack) {
      log('Error initializing Firebase Messaging: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'nalaseva_channel_v2',
        'Nalaseva Notifications',
        channelDescription: 'Notifikasi antrean dan info penting dari Nalaseva',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'app_icon',
        color: AppTheme.primaryColor, // Emerald Green - warna primary NalaSeva
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      
      await _localNotificationsPlugin.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Notifikasi',
        body: message.notification?.body ?? '',
        notificationDetails: platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    } catch (e, stack) {
      log('Error showing local notification: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<bool> hasNotificationPermission() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      log('FCM Token: $token');
      return token;
    } catch (e) {
      log('Failed to get FCM Token: $e');
      return null;
    }
  }
}
