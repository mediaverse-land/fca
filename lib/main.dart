
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mediaverse/app/common/utils/firebase_controller.dart';
import 'package:mediaverse/app/pages/channel/view.dart';
import 'package:mediaverse/app/pages/wrapper/logic.dart';
import 'package:mediaverse/app/pages/wrapper/state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import 'app/common/app_color.dart';
import 'app/common/app_route.dart';
import 'app/common/base/localization_service.dart';


void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  print('Token : ${GetStorage().read('token')}');
  var details = await FlutterLocalNotificationsPlugin()
      .getNotificationAppLaunchDetails();

  try {
    initNotif();
  }  catch (e) {
    // TODO
  }
  if (details!=null&&details.didNotificationLaunchApp) {
    print(details!.notificationResponse!.payload);
  }
 try {
   await FirebaseController().init();
 }  catch (e) {
   // TODO
 }
  runApp(Sizer(builder: (context, orientation, deviceType) {
    return const MyApp();
  }));
}

void initNotif() async{


  await Permission.notification.isDenied.then((value) {
    if (value) {
      print('initNotif');
      Permission.notification.request();
    }
  });
}
class MyApp extends StatefulWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MediaVerse',
      getPages: PageRoutes.routes,
      initialRoute: PageRoutes.SPLASH,
      translations: LocalizationService(),
      debugShowCheckedModeBanner: false,
      locale: LocalizationService().getCurrentLocale(),
      fallbackLocale:LocalizationService.fallBackLocale,
      themeMode: AppTheme().getCurrentTheme(),
      theme: AppTheme.darkMode,
      darkTheme:  AppTheme.darkMode,
      // navigatorObservers: <NavigatorObserver>[MyApp.observer],

    );
  }
}
