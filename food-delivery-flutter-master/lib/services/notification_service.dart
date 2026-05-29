import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'logger_service.dart';

/// Top-level FCM background handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log.info('[FCM] Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'fooddash_orders';
  static const _channelName = 'Order Updates';
  static const _channelDesc = 'Notifications about your order status';

  int _notifId = 0;

  /// Call once at app start (after Firebase.initializeApp).
  Future<void> init() async {
    if (kIsWeb) return;

    // ── Local notifications init ──────────────────────────────────────────
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log.info('[Notif] Tapped notification id=${response.id}');
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // ── FCM ───────────────────────────────────────────────────────────────
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS / Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground messages → show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log.info('[FCM] Foreground message: ${message.notification?.title}');
      final notif = message.notification;
      if (notif != null) {
        showOrderNotification(
          title: notif.title ?? 'FoodDash',
          body: notif.body ?? '',
        );
      }
    });

    log.info('[Notif] NotificationService initialized.');
  }

  /// Shows a local notification immediately (e.g. when order status changes).
  Future<void> showOrderNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      _notifId++,
      title,
      body,
      details,
      payload: payload,
    );
    log.info('[Notif] Showed notification: "$title"');
  }

  /// Retrieves the FCM device token (useful for sending targeted pushes).
  Future<String?> getDeviceToken() async {
    if (kIsWeb) return null;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      log.info('[FCM] Device token: $token');
      return token;
    } catch (e, s) {
      log.error('[FCM] getToken failed', e, s);
      return null;
    }
  }
}

final notifications = NotificationService.instance;
