import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety_framework/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:women_safety_framework/widgets/home_widgets/safehome/batteryMonitoring.dart';
import 'package:workmanager/workmanager.dart';

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
