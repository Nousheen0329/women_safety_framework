import 'package:flutter/material.dart';
import 'package:background_sms/background_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'customizeEmergencyAlert.dart';

class SafeHome extends StatefulWidget {
  SafeHome({Key? key}) : super(key: key);
  @override
  _SafeHomeState createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<String> _contacts = [];
  bool isSendingSOS = false;

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Load contacts on startup
  }



  // Load contacts securely
  Future<void> _loadContacts() async {
    String? storedContacts = await _secureStorage.read(key: "emergency_contacts");
    if (storedContacts != null && storedContacts.isNotEmpty) {
      setState(() {
        _contacts = List<String>.from(jsonDecode(storedContacts));
      });
    }
  }

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

  Future<void> requestSMSPermission() async {
    PermissionStatus status = await Permission.sms.status;
    if (status.isDenied) {
      Fluttertoast.showToast(msg: "SMS permission denied.");
      await Permission.sms.request();
    } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
  }

  Future<void> sendSOSAlert() async {
    if (_contacts.isEmpty) {
      Fluttertoast.showToast(msg: "No emergency contacts added.");
      return;
    }
    Position? position = await _getCurrentLocation();
    String locationUrl = "";
    if(position!=null){
      locationUrl = "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
    }
    else{
      Fluttertoast.showToast(msg: "Location was not read.");
      return;
    }

    String message = "I am in danger! Please help. My location: $locationUrl.\n";
    setState(() {
      isSendingSOS = true;
    });
    for (String contact in _contacts) {
      SmsStatus result = await BackgroundSms.sendMessage(phoneNumber: contact, message: message);
      if (result == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "SOS alert sent to contact ${contact}");
      } else {
        Fluttertoast.showToast(msg: "Alert not sent to contact ${contact}, please try again");
      }
      await Future.delayed(Duration(milliseconds: 5000)); // Add delay
    }
    setState(() {
      isSendingSOS = false; // ✅ Hide loading indicator
    });
  }

  Future<void> _navigateToCustomizeAlert() async {
    final updatedContacts = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomizeAlertPage()),
    );
    if (updatedContacts != null) {
      setState(() {
        _contacts = updatedContacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            await requestSMSPermission();
            sendSOSAlert();
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              height: 150,
              width: MediaQuery.of(context).size.width * 0.8,
              child: isSendingSOS ? Row(
                children: [
                  CircularProgressIndicator(),
                  Text("Sending SOS..."),
                  ],
                  )
                : Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                          "Send Location Alert",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          )
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/route.jpg', fit: BoxFit.contain, height: 150, ),
                  ),
                ],
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            await _navigateToCustomizeAlert();
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.8,
              alignment: Alignment.center,
              child: Text("Customize Emergency Alert", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ],
    );
  }
}
