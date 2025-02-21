import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator package for current location

class HospitalCard extends StatelessWidget {
  final Future<void> Function(String, String, Position) onMapFunction;  // Modified to accept Position
  final Future<List<Map<String, String>>> hospitalsFuture;

  const HospitalCard({
    Key? key,
    required this.onMapFunction,
    required this.hospitalsFuture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: hospitalsFuture, // The async data you're fetching
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Show error message
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hospitals available.')); // Show no data message
        } else {
          // Data is available
          final hospitals = snapshot.data!;

          return SingleChildScrollView(  // Wrap the Column with SingleChildScrollView
            child: Column(
              children: hospitals.map((hospital) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('Hospital'),
                    subtitle: Text('Lat: ${hospital['latitude']}, Lng: ${hospital['longitude']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.map),
                      onPressed: () async {
                        // Fetch current position from Geolocator
                        Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                        // Pass latitude, longitude, and current position to onMapFunction
                        String latitude = hospital['latitude']!;
                        String longitude = hospital['longitude']!;
                        onMapFunction(latitude, longitude, currentPosition);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
