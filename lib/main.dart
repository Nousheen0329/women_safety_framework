import 'dart:convert';

import 'package:background_sms/background_sms.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety_framework/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:women_safety_framework/widgets/home_widgets/safehome/batteryMonitoring.dart';
import 'package:women_safety_framework/widgets/home_widgets/safehome/SafeHome.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shake_detector/shake_detector.dart';

import 'backgroundSos.dart';
import 'fetchWorkplaceDetails.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://rqvbirgxhgdsdxlijvmc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxdmJpcmd4aGdkc2R4bGlqdm1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk4OTk5MTUsImV4cCI6MjA1NTQ3NTkxNX0.Bd83c3RyN6nsurtv8DoN3ddGzCO-Uv3aoUXWGVY2oQA',
  );

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Set to false for production
  );

  final storage = FlutterSecureStorage();
  String? isGestureMonitoringEnabled = await storage.read(key: "gesture_monitoring_enabled");
  if (isGestureMonitoringEnabled == "true"){
    await initializeBackgroundService();
    await SOSService.initializeNotifications(); // Initialize notifications
  }

  String? isEnabled = await storage.read(key: "battery_monitoring_enabled");
  if (isEnabled == "true") {
    print("Registering");
    Workmanager().registerPeriodicTask(
        "1", // Unique ID for the task
        "battery_monitor_task_periodic",
        frequency: Duration(minutes:15),
        initialDelay: Duration(seconds:5)
    );
    Workmanager().registerOneOffTask(
      "oneTimeTask",
      "battery_monitor_task",
      initialDelay: Duration(seconds: 5),
    );
  }
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  print('Entered Dispatcher');
  Workmanager().executeTask((task, inputData) async {
    if (task == "battery_monitor_task") {
      print('Entered Dispatcher Block for battery monitor task');
      await checkBatteryLevel();
    }
    return Future.value(true);
  });
}

void stopBatteryMonitoring() async {
  await Workmanager().cancelByUniqueName("battery_monitor_task");
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  print('Hi this is initializeBackgroundService');
  service.startService();
}


@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}

ShakeDetector? shakeDetector;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  print('Service Started');
  if (service is AndroidServiceInstance) {
    print('inside this if block: service is AndroidServiceInstance');
    service.on("setAsForeground").listen((event) {
      service.setAsForegroundService();
    });
  }

  service.on("sendSOS").listen((event) {
    print('sendSos invoked');
    SOSService.sendSOSAlert();
  });

  print('Before initializing ShakeDetector.autoStart');
  ShakeDetector.autoStart(
    onShake: () {
      print('Device has been shook');
      SOSService.sendSOSAlert();
      service.invoke("sendSOS");
    },
    shakeThresholdGravity: 2.5, // Adjust shake sensitivity
  );

  print('After initializing ShakeDetector.autoStart');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EmpowerHer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
