import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:patients/firebase_options.dart';
import 'package:patients/utils/storage.dart';
import 'package:patients/views/dashboard/appointments/appointments_ctrl.dart';
import 'package:patients/views/dashboard/dashboard_ctrl.dart';
import 'package:patients/views/preload.dart';
import 'package:patients/utils/routes/route_methods.dart';
import 'package:patients/utils/routes/route_name.dart';
import 'package:patients/utils/service/notification_service.dart';
import 'package:patients/utils/theme/light.dart';
import 'package:patients/views/restart.dart';
import 'package:toastification/toastification.dart';
import 'utils/config/app_config.dart';

Future<void> main() async {
  await GetStorage.init();
  GestureBinding.instance.resamplingEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Color(0xFF2563EB), statusBarIconBrightness: Brightness.light));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await preload();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationClick(message);
  });
  terminatedNotification();
  runApp(const RestartApp(child: MyApp()));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String? lastHandledMessageId = await read('notificationKey');
  if (message.messageId != null && message.messageId != lastHandledMessageId) {
    await write('notificationKey', message.messageId);
    await notificationService.init();
    _handleNotificationClick(message);
  }
}

void terminatedNotification() async {
  String? lastHandledMessageId = await read('notificationKey');
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null && initialMessage.messageId != lastHandledMessageId) {
    await write('notificationKey', initialMessage.messageId);
    await notificationService.init();
    _handleNotificationClick(initialMessage);
  }
}

void _handleNotificationClick(RemoteMessage message) async {
  final ctrl = Get.isRegistered<DashboardCtrl>() ? Get.find<DashboardCtrl>() : Get.put(DashboardCtrl());
  ctrl.changeTab(2);
  final appointmentsCtrl = Get.isRegistered<AppointmentsCtrl>() ? Get.find<AppointmentsCtrl>() : Get.put(AppointmentsCtrl());
  if (message.notification?.title == "Request Accepted") {
    appointmentsCtrl.selectedFilter.value = "Accepted";
  } else if (message.notification?.title == "Request Cancelled") {
    appointmentsCtrl.selectedFilter.value = "Cancelled";
  } else if (message.notification?.title == "Appointment Completed") {
    appointmentsCtrl.selectedFilter.value = "Completed";
  }
  appointmentsCtrl.changeFilter(appointmentsCtrl.selectedFilter.value);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        builder: (BuildContext context, widget) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: widget!,
          );
        },
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        getPages: AppRouteMethods.pages,
        initialRoute: AppRouteNames.splash,
      ),
    );
  }
}
