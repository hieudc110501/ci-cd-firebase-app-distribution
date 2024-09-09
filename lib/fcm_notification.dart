import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fcm_app/shared_prefs.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class FcmNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'high_important_channel',
    'high_important_channel_name',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    
  );

  initNotifications() async {
    await _messaging.requestPermission();
    String? fcm = await _messaging.getToken();
    SharedPrefs().setFCM(fcm ?? '');
    //firebaseInit();
    await initPushNotification();
    //await initLocalNotifications();
  }

  //register topic
  registerTopic() async {
    if (Platform.isIOS) {
      String? apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        await _messaging.subscribeToTopic('members-v2');
      } else {
        await Future<void>.delayed(
          const Duration(
            seconds: 3,
          ),
        );
        apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          await _messaging.subscribeToTopic('members-v2');
        }
      }
    } else {
      await _messaging.subscribeToTopic('members-v2');
    }
  }

  Future initPushNotification() async {
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        sound: true,
        badge: true,
        alert: true,
      );
      _messaging.getInitialMessage().then((message) =>
          Future.delayed(const Duration(seconds: 1))
              .then((value) => handleMessage(message)));
      FirebaseMessaging.onMessageOpenedApp.listen((message) =>
          Future.delayed(const Duration(seconds: 1))
              .then((value) => handleMessage(message)));
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        if (Platform.isAndroid) {
          _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                playSound: true,
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher'
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: jsonEncode(message.toMap()),
          );
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> initLocalNotifications() async {
    try {
      var androidInitialize =
          const AndroidInitializationSettings('mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentSound: true,
      );
      var initializationsSettings = InitializationSettings(
        android: androidInitialize,
        iOS: initializationSettingsDarwin,
      );
      await _flutterLocalNotificationsPlugin.initialize(initializationsSettings,
          onDidReceiveNotificationResponse: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
        handleMessage(message);
      });

      final platform = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await platform?.createNotificationChannel(_androidChannel);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //request permission for notification
  Future<void> requestNotificationPermission() async {
    final bool isNotificationPermissionGranted =
        await Permission.notification.isGranted;

    if (!isNotificationPermissionGranted) {
      await Permission.notification.request();
    }

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  //handle message
  handleMessage(RemoteMessage? message) {
    if (message != null) {}
    debugPrint('handleMessage');
    debugPrint(message.toString());
  }

  //handle background message
  Future<void> handleBackgroundMessage(RemoteMessage? message) async {
    if (message != null) {}
    debugPrint('handleBackgroundMessage');
    debugPrint(message.toString());
  }

  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        //initLocalNotifications();
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      _androidChannel.id.toString(),
      _androidChannel.name.toString(),
      channelDescription: 'channelDescription',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title.toString(),
      message.notification?.body.toString(),
      notificationDetails,
    );
  }
}
