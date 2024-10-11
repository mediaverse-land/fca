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

import '../../../firebase_options.dart';
import '../../pages/media_suit/logic.dart';
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
    //  debugger();
      sendToAssetPage(s.payload ?? "");
    });
  }

  void listenToFCMMessages() {
    print('FirebaseController.listenToFCMMessages 1');
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("onMessageOpenedApp: $message");

      FirebaseController.sendToAssetPage( jsonEncode(message.data));
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FirebaseController.listenToFCMMessages = ${message} - ${Get.currentRoute}');
      if(Get.currentRoute.contains(PageRoutes.MEDIASUIT)){
        if (Get.find<MediaSuitController>().isloadingSubmit.value) {
          Get.find<MediaSuitController>().isloadingSubmit(false);
          sendToAssetPage(jsonEncode(message.data));
        }
        if (Get.find<MediaSuitController>().isWaitingAssetConvert.value) {
          Get.find<MediaSuitController>().isWaitingAssetConvert(false);

          Get.find<MediaSuitController>().setAssetLoadingValue(jsonEncode(message.data));
        }
      }else{
        showNotification(message);
      }
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
          payload: jsonEncode(message.data));
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
    try {
      var json = jsonDecode(s);
      var json2 = json['result'].toString();
      print('FirebaseController.sendToAssetPage 2 1   = ${json}');
      print('FirebaseController.sendToAssetPage 2 2  =  ${json2.substring(json2.indexOf("media_type")+12,json2.indexOf("asset_id")-2)}');
      print('FirebaseController.sendToAssetPage 2 3  = ${jsonDecode(json['result'])['media_type'].toString()} - ${json['result'].toString()}');
      print('FirebaseController.sendToAssetPage 3');

      String route = PageRoutes.DETAILIMAGE;
      print('FirebaseController.sendToAssetPage 3');

      switch (jsonDecode(json['result'])['media_type'].toString()) {
        case "1":
          route = PageRoutes.DETAILTEXT;
        case "2":
          route = PageRoutes.DETAILIMAGE;
        case "3":
          route = PageRoutes.DETAILMUSIC;
        case "4":
          route = PageRoutes.DETAILVIDEO;
      }
      var id = jsonDecode(json['result'])['id'].toString();
      Get.toNamed(route, arguments: {'id': id}, preventDuplicates: false);
    } catch (e) {
      // TODO
      print('FirebaseController.sendToAssetPage = ${e}');
    }
  }
}
