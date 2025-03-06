import 'dart:convert';
import 'package:background_sms/background_sms.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

final storage = FlutterSecureStorage();
final Battery _battery = Battery();

Future<Position?> _getCurrentLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      Fluttertoast.showToast(msg: "Location permission denied.");
      return null;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    Fluttertoast.showToast(msg: "Location permission permanently denied. Please enable from settings to send location.");
    openAppSettings();
    return null;
  }
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

Future<void> checkBatteryLevel() async {
  // Check if the user has enabled battery monitoring
  String? isEnabled = await storage.read(key: "battery_monitoring_enabled");
  if (isEnabled != "true") return;

  // Get battery level
  int batteryLevel = await _battery.batteryLevel;
  print("Battery Level ${batteryLevel}");
  if (batteryLevel <= 10 ) {
    await sendEmergencyAlert("My phone's battery is less than 10%.");
  }
}

Future<void> sendEmergencyAlert(String batteryLevelMessage) async {
  String? storedContacts = await storage.read(key: "emergency_contacts");
  List<String> contacts = [];
  if (storedContacts != null && storedContacts.isNotEmpty) {
      contacts = List<String>.from(jsonDecode(storedContacts));
  }
  Position? position = await _getCurrentLocation();
  String locationUrl = "";
  if(position!=null){
    locationUrl = "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
  }
  String message = batteryLevelMessage + 'Here is my last location: $locationUrl.';
  for (String contact in contacts) {
    SmsStatus result = await BackgroundSms.sendMessage(phoneNumber: contact, message: message);
    if (result == SmsStatus.sent) {
      print('Message Sent to ${contact}');
    } else {
      print('Message Failed');
    }
    await Future.delayed(Duration(milliseconds: 5000)); // Add delay
  }
}
