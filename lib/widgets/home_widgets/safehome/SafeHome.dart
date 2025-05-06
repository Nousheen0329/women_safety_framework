import 'package:flutter/material.dart';
import 'package:background_sms/background_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:women_safety_framework/landing_page.dart';
import 'dart:convert';

import '../../../fetchWorkplaceDetails.dart';
import '../../../reusable_widgets/textStyles.dart';
import 'customizeEmergencyAlert.dart';

class SafeHome extends StatefulWidget {
  SafeHome({Key? key}) : super(key: key);
  @override
  _SafeHomeState createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<String> _contacts = [];
  List<String> _workplaceContacts = [];
  bool isSendingSOS = false;

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Load contacts on startup
  }



  // Load contacts securely
  Future<void> _loadContacts() async {
    String? storedContacts = await _secureStorage.read(key: "emergency_contacts");
    String? workplaceContactsData = await _secureStorage.read(key: "workplace_emergency_contacts");

    if (storedContacts != null && storedContacts.isNotEmpty) {
      setState(() {
        _contacts = List<String>.from(jsonDecode(storedContacts));
      });
    }
    if (workplaceContactsData != null && workplaceContactsData.isNotEmpty) {
      setState(() {
        _workplaceContacts = List<String>.from(jsonDecode(workplaceContactsData));
      });
    }
  }

  Future<void> sendSOSAlert() async {
    if (_contacts.isEmpty) {
      Fluttertoast.showToast(msg: "No emergency contacts added.");
      return;
    }
    bool isAtWorkplace = await checkIfAtWorkplace();
    List<String> recipients = _contacts;
    if (isAtWorkplace) {
      recipients.addAll(_workplaceContacts);
    }

    Position? position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);;
    String locationUrl = "";
    if(position!=null){
      locationUrl = "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
    }
    else{
      Fluttertoast.showToast(msg: "Location was not read.");
      return;
    }

    String message = "You have received an SOS. This is an emergency alert. My location: $locationUrl.\n";
    setState(() {
      isSendingSOS = true;
    });
    for (String contact in recipients) {
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
          onTap: () {
            sendSOSAlert();
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              height: 150,
              width: MediaQuery.of(context).size.width * 0.8,
              child: isSendingSOS ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  normalText("Sending SOS..."),
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
              child: Text("Customize Emergency Alert", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.deepPurple)),
            ),
          ),
        ),
      ],
    );
  }
}

