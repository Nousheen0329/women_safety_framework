import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class SelectLocationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Geofence Location")),
      body: FlutterLocationPicker(
        initPosition: LatLong(17.401516, 78.484511), // Default location
        selectLocationButtonText: "Confirm Location",
        onPicked: (pickedData) {
            Navigator.pop(context, LatLong(pickedData.latLong.latitude, pickedData.latLong.longitude));
        },
      ),
    );
  }
}
