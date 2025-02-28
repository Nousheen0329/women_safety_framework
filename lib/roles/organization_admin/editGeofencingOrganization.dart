import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:women_safety_framework/reusable_widgets/textStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../reusable_widgets/buttons.dart';
import '../../widgets/home_widgets/safehome/selectLocationPage.dart'; // Import Firestore

class GeofencingWidgetOrganization extends StatefulWidget {
  final String? organizationId;
  const GeofencingWidgetOrganization({
    Key? key,
    required this.organizationId,
  }) : super(key: key);

  @override
  _GeofencingWidgetOrganizationState createState() => _GeofencingWidgetOrganizationState();
}

class _GeofencingWidgetOrganizationState extends State<GeofencingWidgetOrganization> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  double _geofenceRadius = 0;
  double _geofenceLatitude = 0;
  double _geofenceLongitude = 0;
  void initState() {
    super.initState();
    _loadGeofenceSettings();
  }

  Future<void> _loadGeofenceSettings() async {
    try {
      print("Org ID ${widget.organizationId}");
      // Try fetching from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('organization')
          .doc(widget.organizationId)
          .get();
      print("Org Snapshot ${snapshot.exists}");
      if (snapshot.exists) {
        Map<String, dynamic> geofenceData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _geofenceLatitude = geofenceData["latitude"] ?? 0.0;
          print("Latitude $_geofenceLatitude");
          _geofenceLongitude = geofenceData["longitude"] ?? 0.0;
          _geofenceRadius = geofenceData["radius"] ?? 0.0;

          _latitudeController.text = _geofenceLatitude.toString();
          _longitudeController.text = _geofenceLongitude.toString();
        });

        return;
      }
    } catch (e) {
      print("Failed to load geofence from Firestore: $e");
    }
  }

  Future<void> _saveGeofenceSettings() async {
    double latitude = double.tryParse(_latitudeController.text) ?? _geofenceLatitude;
    double longitude = double.tryParse(_longitudeController.text) ?? _geofenceLongitude;
    double radius = double.tryParse(_radiusController.text) ?? _geofenceRadius;

    setState(() {
      _geofenceLatitude = latitude;
      _geofenceLongitude = longitude;
      _geofenceRadius = radius;
    });

    try {
      await FirebaseFirestore.instance.collection('organization').doc(widget.organizationId).update({
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Geofence updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update geofence: $e")),
      );
    }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    normalText('Current Geofence Settings'),
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

        buildSectionTitle("Setup Geofencing"),

        SizedBox(height:10),
        TextField(controller: _radiusController, decoration: InputDecoration(labelText: "Radius (meters)",
            labelStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white
            ),
            border: OutlineInputBorder()),
            keyboardType: TextInputType.number
        ),
        CustomButton(
          text: "Pick Lat/Lng on Map",
          onPressed: _pickLocation,
          icon: const Icon(Icons.pin_drop),
        ),
        CustomButton(
          text: "Save Changes",
          onPressed: _saveGeofenceSettings,
          icon: const Icon(Icons.add_location_alt_sharp),
        ),
      ],
    );
  }
}

