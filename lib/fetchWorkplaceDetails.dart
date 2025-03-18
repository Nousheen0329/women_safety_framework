import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

Future<void> fetchAndStoreWorkplaceData() async {
  final storage = FlutterSecureStorage();
  String? userId = await storage.read(key: 'working_woman_uid');
  if(userId==null){
    print('Not registered with workplace');
    return;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    DocumentSnapshot userDoc = await firestore
        .collection('working_women')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data != null) {

        if (data.containsKey('organization_id')) {
          var organizationId = data['organization_id'];

          //For workplace emergency contacts
          QuerySnapshot snapshot = await firestore
              .collection('organization')
              .doc(organizationId)
              .collection('security_team')
              .get();

          List<String> securityContacts = [];
          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            if (data.containsKey("phone")) {
              securityContacts.add(data["phone"]);
            };
          }
          if (securityContacts.isNotEmpty) {
            await storage.write(key: "workplace_emergency_contacts", value: jsonEncode(securityContacts));
            print('After Storing ${securityContacts}');
            Fluttertoast.showToast(msg: "Workplace Security team contacts retrieved successfully!");
          } else {
            Fluttertoast.showToast(msg: "No security team contacts found for workplace.");
          }

          //For geofence settings
          DocumentSnapshot snapshotGeofence = await firestore
              .collection('organization')
              .doc(organizationId)
              .get();
          if(snapshotGeofence.exists){
            Map<String, dynamic> snapshotGeofenceData = snapshotGeofence.data() as Map<String, dynamic>;
            if (snapshotGeofenceData.containsKey('latitude') && snapshotGeofenceData.containsKey('longitude') && snapshotGeofenceData.containsKey('radius')) {
              Map<String, dynamic> geofenceData = {
                "latitude": snapshotGeofenceData['latitude'],
                "longitude": snapshotGeofenceData['longitude'],
                "radius": snapshotGeofenceData['radius'],
              };
              await storage.write(key: "workplace_geofence_settings", value: jsonEncode(geofenceData));
              print('After Storing ${geofenceData}');
              Fluttertoast.showToast(msg: "Workplace Geofence configuration retrieved successfully!");
            }
            else {
              Fluttertoast.showToast(msg: "No geofence configuration found for workplace.");
            }
          }
      }
      }
    } else {
      Fluttertoast.showToast(msg: "No workplace data found for user.");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Error fetching workplace data: $e");
  }
}

Future<bool> checkIfAtWorkplace() async {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? geofenceData = await storage.read(key: "workplace_geofence_settings");

  if (geofenceData == null) {
    return false; // No geofence data found
  }

  try {
    Map<String, dynamic> geofence = jsonDecode(geofenceData);
    double geofenceLat = geofence["latitude"];
    double geofenceLon = geofence["longitude"];
    double geofenceRadius = geofence["radius"];

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double distance = Geolocator.distanceBetween(position.latitude, position.longitude, geofenceLat, geofenceLon);

    return distance <= geofenceRadius;
  } catch (e) {
    Fluttertoast.showToast(msg: "Failed to get location for workplace check.");
    return false;
  }
}

