import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Top-level handler required by FCM for background/terminated messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the time this runs.
  // We don't show a local notification here because FCM shows the system
  // notification automatically when the app is in the background/terminated.
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<String>? _tokenRefreshSub;

  static const _channelId = 'athar_high_importance';
  static const _channelName = 'Athar Notifications';

  /// Called once from main() after Firebase.initializeApp().
  Future<void> init() async {
    // Register the background handler before any other FCM setup.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _setupLocalNotifications();
    await _requestPermissions();
    await _configureFcm();
  }

  // ── Local notifications ────────────────────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create the Android notification channel.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    // payload is the notification type; route accordingly.
    _routeFromType(response.payload);
  }

  // ── Permissions ────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() => requestPermissions();

  /// Requests notification permission and returns true if granted.
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    if (Platform.isIOS) {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    return true;
  }

  /// Returns true if the user has already granted notification permission.
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    if (Platform.isIOS) {
      final settings = await _fcm.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    return true;
  }

  /// Subscribe this device to an FCM topic (e.g. 'booking_notifications').
  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);

  /// Unsubscribe this device from an FCM topic.
  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);

  // ── FCM configuration ──────────────────────────────────────────────────────

  Future<void> _configureFcm() async {
    // Foreground: show as local notification (FCM suppresses UI by default).
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened from a background notification tap.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _routeFromType(message.data['type']);
    });

    // App launched from a terminated-state notification tap.
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      _routeFromType(initial.data['type']);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['type'],
    );
  }

  // ── Routing ────────────────────────────────────────────────────────────────

  /// Override this with a real navigator key once the app has a route system.
  static GlobalKey<NavigatorState>? navigatorKey;

  void _routeFromType(String? type) {
    if (type == null || navigatorKey == null) return;
    final context = navigatorKey!.currentContext;
    if (context == null) return;

    // All notification types currently route to the notifications screen.
    // Extend this switch when deep-linking to specific content screens.
    switch (type) {
      case 'contribution_submitted':
      case 'contribution_approved':
      case 'contribution_rejected':
      case 'trip_submitted':
      case 'trip_approved':
      case 'trip_rejected':
      case 'booking_new':
      case 'booking_approved':
      case 'booking_cancelled':
      case 'booking_reminder':
      case 'booking_auto_completed':
      case 'guide_verified':
      case 'points_awarded':
        Navigator.of(context).pushNamed('/notifications');
        break;
    }
  }

  // ── Token lifecycle ────────────────────────────────────────────────────────

  /// Call after a successful login to register this device's FCM token.
  Future<void> registerToken(String userId) async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveToken(userId, token);
    }
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub =
        _fcm.onTokenRefresh.listen((newToken) => _saveToken(userId, newToken));
  }

  Future<void> _saveToken(String userId, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  /// Call on logout to remove the current device token.
  Future<void> removeToken(String userId) async {
    final token = await _fcm.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }
}
