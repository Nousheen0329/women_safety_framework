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
  double _geofenceRadius = 0;
  double _geofenceLatitude = 0;
  double _geofenceLongitude = 0;

  void initState() {
    super.initState();
    _loadGeofenceSettings();
  }

  Future<void> _loadGeofenceSettings() async {
    String? storedGeofence = await _secureStorage.read(
        key: "geofence_settings");
    if (storedGeofence != null) {
      Map<String, dynamic> geofenceData = jsonDecode(storedGeofence);
      setState(() {
        _geofenceLatitude = geofenceData["latitude"];
        _geofenceLongitude = geofenceData["longitude"];
        _geofenceRadius = geofenceData["radius"];
      });
    }
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
                hexStringToColor("CB2B93"),
                hexStringToColor("9546C4"),
                hexStringToColor("5E61F4")
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
                  GeofencingWidget(secureStorage: _secureStorage),
                ],
              ),
            ),
          ),
        ),
        ),
      );
    }
}


