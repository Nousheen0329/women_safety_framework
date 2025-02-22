import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:women_safety_framework/utils/sectionTitle.dart';
import 'dart:convert';
import '../../../utils/color_utils.dart';
import 'selectLocationPage.dart';
import 'package:women_safety_framework/landing_page.dart';

class CustomizeAlertPage extends StatefulWidget {
  @override
  _CustomizeAlertPageState createState() => _CustomizeAlertPageState();
}

class _CustomizeAlertPageState extends State<CustomizeAlertPage> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<String> _contacts = [];
  bool _batteryMonitoring = false;
  bool _geofencingEnabled = false;
  double _geofenceRadius = 0;
  double _geofenceLatitude = 0;
  double _geofenceLongitude = 0;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadSettings();
    _loadGeofenceSettings();
  }

  @override
  void dispose() {
    _contactController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    String? storedContacts = await _secureStorage.read(
        key: "emergency_contacts");
    if (storedContacts != null && storedContacts.isNotEmpty) {
      setState(() {
        _contacts = List<String>.from(jsonDecode(storedContacts));
      });
    }
  }

  void _addContact() {
    String newContact = _contactController.text.trim();
    if (newContact.isNotEmpty) {
      setState(() {
        _contacts.add(newContact);
      });
      _contactController.clear();
    }
  }

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  Future<void> _saveContacts() async {
    await _secureStorage.write(
        key: "emergency_contacts", value: jsonEncode(_contacts));
    Navigator.pop(context, _contacts);
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
        _latitudeController.text = _geofenceLatitude.toString();
        _longitudeController.text = _geofenceLongitude.toString();
      });
    }
  }

  Future<void> _saveGeofenceSettings() async {
    double latitude = double.tryParse(_latitudeController.text) ?? _geofenceLatitude;
    double longitude = double.tryParse(_longitudeController.text) ?? _geofenceLongitude;
    double radius = double.tryParse(_radiusController.text) ?? _geofenceRadius;

    setState(() {
      _geofenceRadius = double.tryParse(_radiusController.text) ?? _geofenceRadius;
    });

    Map<String, dynamic> geofenceData = {
      "latitude": latitude,
      "longitude": longitude,
      "radius": radius,
    };

    await _secureStorage.write(
        key: "geofence_settings", value: jsonEncode(geofenceData));

    _radiusController.clear();
  }

  Future<void> _pickLocation() async {
    LatLong? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectLocationPage()),
    );

    if (selectedLocation != null) {
      setState(() {
        _geofenceLatitude = selectedLocation.latitude;
        _geofenceLongitude = selectedLocation.longitude;
        _latitudeController.text = _geofenceLatitude.toString();
        _longitudeController.text = _geofenceLongitude.toString();
      });

      if (_radiusController.text.isEmpty) {
        _radiusController.text = _geofenceRadius.toString();
      }
    }
  }

  Future<void> _loadSettings() async {
    String? batterySetting = await _secureStorage.read(
        key: "battery_monitoring_enabled");
    String? geofenceSetting = await _secureStorage.read(
        key: "geofencing_enabled");

    setState(() {
      _batteryMonitoring = batterySetting == "true";
      _geofencingEnabled = geofenceSetting == "true";
    });
  }

  Future<void> _saveSettings() async {
    await _secureStorage.write(key: "battery_monitoring_enabled",
        value: _batteryMonitoring.toString());
    await _secureStorage.write(
        key: "geofencing_enabled", value: _geofencingEnabled.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Background Monitoring"),
          content:
          Text("Battery Monitoring and Geofence Alerts require the app to be running on the background. Please ensure that you do not delete the app from recent apps while using your phone. This may affect battery. If you do not need this, it can be disabled."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(),
        body: Container(
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
                  buildSectionTitle('Add and Delete\nEmergency Contacts'),
                  SizedBox(
                    width: MediaQuery.of(context).size.width-30,
                    child: TextField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: "Add Emergency Contact",
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                        ),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),


                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: _addContact,
                      child: Text(
                          "Add Contact",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                        ),
                      )
                  ),

                  SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      shrinkWrap: true, // Prevent unnecessary expansion
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) =>
                          ListTile(
                            title: Text(_contacts[index],
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                            ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteContact(index),
                            ),
                          ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveContacts,
                    child: Text("Save Changes",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                    ),
                  ),

                  SizedBox(height: 10),
                  buildSectionTitle('Background Monitoring'),
                  SwitchListTile(
                    title: Text("Enable Battery Monitoring",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 5.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),),
                    activeTrackColor: Colors.green[400],
                    value: _batteryMonitoring,
                    onChanged: (value) {
                      setState(() {
                        _batteryMonitoring = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text("Enable Geofencing Alerts",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 5.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    activeTrackColor: Colors.green[400],
                    value: _geofencingEnabled,
                    onChanged: (value) {
                      setState(() {
                        _geofencingEnabled = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: Text("Save",
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  Card(
                    elevation: 4, // Adds shadow for a 3D effect
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
                    color: Colors.indigo[800], // Dark background for better contrast
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Current Geofence Settings",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 5.0,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.location_on, color: Colors.lightBlueAccent), // Location icon
                            ],
                          ),
                          Divider(color: Colors.white54), // Light separator
                          buildSettingItem(Icons.map, "Latitude", _geofenceLatitude.toString()),
                          buildSettingItem(Icons.map, "Longitude", _geofenceLongitude.toString()),
                          buildSettingItem(Icons.circle, "Radius", "${_geofenceRadius} meters"),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  buildSectionTitle("Setup Geofencing"),

                  SizedBox(height:10),
                  TextField(controller: _radiusController, decoration: InputDecoration(labelText: "Radius (meters)",
                      labelStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                      ),
                      border: OutlineInputBorder()), keyboardType: TextInputType.number),

                  SizedBox(height: 10),
                  ElevatedButton.icon(onPressed: _pickLocation,
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                    minimumSize: Size(MediaQuery.of(context).size.width-30, 40),
                    ),
                    icon: const Icon(Icons.pin_drop),
                    label: Text("Pick Lat/Lng on Map",
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                  ),

                  SizedBox(height: 10),
                  ElevatedButton(onPressed: _saveGeofenceSettings, child: Text("Save Geofence Settings",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      );
    }
}


