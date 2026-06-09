import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../router/app_router.dart';
import '../../features/payment/logic/payment_provider.dart';
import '../../features/patient/logic/patient_provider.dart';
import '../../features/pharmacy/logic/pharmacy_provider.dart';
import '../../features/doctor/logic/doctor_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Handling a background message: ${message.messageId}');
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void _handleMessageData(Map<String, dynamic> data) {
    try {
      log('Processing FCM Message Data: $data');
      final type = data['type']?.toString();
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        if (type == 'payment_updated' || type == 'payment') {
          context.read<PaymentProvider>().fetchMyPayments();
          context.read<PatientProvider>().fetchMyQueues();
        } else if (type == 'queue_updated' || type == 'queue') {
          context.read<PatientProvider>().fetchMyQueues();
          context.read<DoctorProvider>().fetchMyQueues();
        } else if (type == 'prescription_updated' || type == 'prescription') {
          context.read<PharmacyProvider>().fetchPharmacyQueues();
        }
      }
    } catch (e) {
      log('Error handling message data: $e');
    }
  }

  Future<void> initialize() async {
    // 1. Setup local notifications for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        log('Notification clicked: ${details.payload}');
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!);
            if (data is Map<String, dynamic>) {
              _handleMessageData(data);
            }
          } catch (e) {
            log('Error parsing notification click payload: $e');
          }
        }
      },
    );

    // 2. Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Request permissions for iOS & Android
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    // Explicitly request notification permission for Android 13+ (API level 33+)
    final bool? androidGranted = await androidImplementation?.requestNotificationsPermission();
    log('Android notification permission status: $androidGranted');

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
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
        _showLocalNotification(message);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'nalaseva_channel', // id
      'Nalaseva Notifications', // title
      channelDescription: 'Notifikasi antrean dan info penting dari Nalaseva',
      importance: Importance.max,
      priority: Priority.high,
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
