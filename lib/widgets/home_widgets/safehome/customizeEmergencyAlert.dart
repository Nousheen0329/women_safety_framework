import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:women_safety_framework/widgets/home_widgets/safehome/editMonitoringSettings.dart';
import 'dart:convert';
import '../../../main.dart';
import '../../../utils/color_utils.dart';
import 'editEmergencyContacts.dart';
import 'editGeofencing.dart';
import 'selectLocationPage.dart';
import '../../../reusable_widgets/buttons.dart';

class CustomizeAlertPage extends StatefulWidget {
  @override
  _CustomizeAlertPageState createState() => _CustomizeAlertPageState();
}

class _CustomizeAlertPageState extends State<CustomizeAlertPage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  void initState() {
    super.initState();
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(),
        body:
        Container(
            decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:[
                hexStringToColor('9AA1D9'),
                hexStringToColor('9070BA'),
              ], // Vibrant gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  EmergencyContactsWidget(secureStorage: _secureStorage),
                  SizedBox(height: 10),
                  EditMonitoringSettings(secureStorage: _secureStorage),
                  SizedBox(height:10),
                ],
              ),
            ),
          ),
        ),
        ),
      );
    }
}


