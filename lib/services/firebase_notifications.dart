import 'dart:async';

import 'package:apps_against_fellowship/config/config.dart';
import 'package:apps_against_fellowship/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Note: data and messageId are the only useful properties in message
  print('fn background');
  // print(message.data); // Object
  // print(message.messageId); // 16 digit #

  FirebaseNotifications().showNotificationOnForeground(message);
}

// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse notificationResponse) {
//   // handle action
//   print('on tap yo');
// }

class FirebaseNotifications {
  FirebaseMessaging fbm = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin noticesPlugin =
      FlutterLocalNotificationsPlugin();

  final NotificationDetails notificationDetail = const NotificationDetails(
    android: AndroidNotificationDetails(
      "firebase_notifications_channel",
      "FB Notifications Channel",
      icon: 'icon_small',
      priority: Priority.max,
      importance: Importance.max,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
    ),
  );

  Future<void> initializeNotificationListeners() async {
    // print('listeners initialized');

    await fbm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // TODO: try to get the onDidReceiveBackgroundNotificationResponse to be active
    // This is kinda right, but not really. We want to initialize it but not
    // trigger the initial request popup (which I believe this will do).
    // if (await Permission.notification.status == PermissionStatus.granted ||
    //     await Permission.notification.status == PermissionStatus.limited ||
    //     await Permission.notification.status == PermissionStatus.provisional) {
    //   print('has permission to do the things');

    //   // TODO: needed (?); not sure if this is called anywhere
    //   // void initialize() {
    //   //   const AndroidInitializationSettings androidSettings =
    //   //       AndroidInitializationSettings('icon_small');

    //   //   const DarwinInitializationSettings iosSettings =
    //   //       DarwinInitializationSettings(
    //   //     requestAlertPermission: true,
    //   //     requestBadgePermission: true,
    //   //     requestCriticalPermission: true,
    //   //     requestSoundPermission: true,
    //   //   );
    //   //   const InitializationSettings initializationSettings =
    //   //       InitializationSettings(
    //   //     android: androidSettings,
    //   //     iOS: iosSettings,
    //   //   );

    //   //   noticesPlugin.initialize(
    //   //     initializationSettings,
    //   //   );
    //   // }

    //   const AndroidInitializationSettings androidSettings =
    //       AndroidInitializationSettings('icon_small');

    //   const DarwinInitializationSettings iosSettings =
    //       DarwinInitializationSettings(
    //     requestAlertPermission: true,
    //     requestBadgePermission: true,
    //     requestCriticalPermission: true,
    //     requestSoundPermission: true,
    //   );
    //   const InitializationSettings initializationSettings =
    //       InitializationSettings(
    //     android: androidSettings,
    //     iOS: iosSettings,
    //   );

    //   await noticesPlugin.initialize(
    //     initializationSettings,
    //     onDidReceiveNotificationResponse:
    //         (NotificationResponse notificationResponse) async {
    //       print('got it');
    //     },
    //     onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    //   );
    // }

    // Terminated (onLaunch)
    // Update: only appears on app load w/ a null message
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      print('fn terminated');
      // print('message: $message');
      if (message != null) {
        // print('termination ping');
        FirebaseNotifications().showNotificationOnForeground(message);
      }
    });

    // Foreground (onMessage)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('fn foreground ping');
      // print(message.data);
      // print(message.data['title']);
      // print(message.messageId);

      FirebaseNotifications().showNotificationOnForeground(message);
    });

    // Background (onResume / onClick)
    // Update: this doesn't seem to trigger (ever..)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('fn on click');
      // print(message.data);
      // print(message.data['payload']);

      goRouter.goNamed('thisWeek');
    });

    // Note: adding this here overrode main's onBackgroundMessage handler
    // Then why don't the services above get handled...
    // Terminated does on app open. But the
    // FirebaseMessaging.onBackgroundMessage((message) async {
    //   print('on background tap');
    //   // return () {};
    // });
  }

  void showCustomNotification(String title, String body) {
    print('custom');

    noticesPlugin.show(
      DateTime.now().microsecond,
      title,
      body,
      notificationDetail,
      // payload: message.data['payload'],
    );
  }

  // TODO: reformat the title and message w/ new data fields
  void showNotificationOnForeground(RemoteMessage message) {
    print('show notification on foreground');
    print(message.data);

    noticesPlugin.show(
      DateTime.now().microsecond,
      message.data['title'],
      message.data['body'],
      notificationDetail,
      payload: message.data['payload'],
    );
  }
}
