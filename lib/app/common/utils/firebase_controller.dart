import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mediaverse/app/common/app_route.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../firebase_options.dart';
import '../RequestInterface.dart';
import '../app_api.dart';

class FirebaseController extends GetxController implements RequestInterface {
  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response) {
    print('FirebaseController.initializeLocalNotifications 1 ');
    // Handle your notification response logic here
  }

  late FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  var box = GetStorage();
  late ApiRequster apiRequster;
  void initNotif() async{


    await Permission.notification.isDenied.then((value) {
      if (value) {
        print('initNotif');
        Permission.notification.request();
      }
    });
  }
  init() async {
    onReady();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (Platform.isIOS) {
      FirebaseMessaging.instance.requestPermission();
    }

    _firebaseMessaging = FirebaseMessaging.instance;
    requestNotificationPermissions();
    initializeLocalNotifications();
    listenToFCMMessages();
    if (box.read("islogin") ?? false) {
      String? token = await FirebaseMessaging.instance.getToken();
      print('FirebaseController.init = ${token}');
      box.write("firebaseToken", token);
      var body = {"token": token};
      apiRequster.request(
          "push-notifications/firebase-tokens", ApiRequster.MHETOD_POST, 1,
          useToken: true, body: body);
      apiRequster.request("firebase?user_id=2", ApiRequster.MHETOD_GET, 500,
          useToken: true);
    }
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    apiRequster = ApiRequster(this, develperModel: false);
  }

  @override
  void onError(String content, int reqCode, bodyError) {
    // TODO: implement onError
  }

  @override
  void onStartReuqest(int reqCode) {
    // TODO: implement onStartReuqest
  }

  @override
  void onSucces(source, int reqCdoe) {
    // TODO: implement onSucces
  }

  void logOut() {
    // apiRequster.request("api/u-crm/sessions/firebase", ApiRequster.METHOD_DELETE, 1,useToken: true,);
  }

  void requestNotificationPermissions() {
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void initializeLocalNotifications() {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse:
        FirebaseController.onDidReceiveBackgroundNotificationResponse,
        onDidReceiveNotificationResponse: (s) {
          sendToAssetPage(s.payload ?? "");
        });
  }

  void listenToFCMMessages() {
    print('FirebaseController.listenToFCMMessages 1');
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("onMessageOpenedApp: $message");

      FirebaseController.sendToAssetPage( jsonEncode(jsonDecode(message.data['result'])));
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        //debugger();
      initNotif();
      print('FirebaseController.listenToFCMMessages = ${message}');
     // debugger();
      showNotification(message);
    });
  }

  void showNotification(RemoteMessage message) {
    //debugger();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'MediaVerse_0',
      'MediaVerse',
      channelDescription: 'MediaVerse Channel Notification',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    try {
      _flutterLocalNotificationsPlugin.show(
          0, // Notification ID
          message.notification?.title, // Notification Title
          message.notification!.body.toString(), // Notification Body
          platformChannelSpecifics,
          //   payload: message.data
          payload: jsonEncode(message.data)

      );
    } catch (e) {
      _flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        message.notification?.title, // Notification Title
        message.notification?.body, // Notification Body
        platformChannelSpecifics,
      );
    }
  }

  static void  sendToAssetPage(String s) {
    print('FirebaseController.sendToAssetPage = ${s}');
    // debugger();
    try {
      var json = jsonDecode(s);
      print('FirebaseController.sendToAssetPage 2  = ${json}');
      String route = PageRoutes.DETAILIMAGE;
      switch (json['class'].toString()) {
        case "1":
          route = PageRoutes.DETAILTEXT;
        case "2":
          route = PageRoutes.DETAILIMAGE;
        case "3":
          route = PageRoutes.DETAILMUSIC;
        case "4":
          route = PageRoutes.DETAILVIDEO;
      }
      var id = json['id'];
      Get.toNamed(route, arguments: {'id': id}, preventDuplicates: false);
    } catch (e) {
      // TODO
      print('FirebaseController.sendToAssetPage = ${e}');
    }
  }
}
