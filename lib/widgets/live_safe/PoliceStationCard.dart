import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator package for current location

class PoliceStationCard extends StatelessWidget {
  final Future<void> Function(String, String, Position) onMapFunction;  // Modified to accept Position
  final Future<List<Map<String, String>>> policeStationsFuture;

  const PoliceStationCard({
    Key? key,
    required this.onMapFunction,
    required this.policeStationsFuture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: policeStationsFuture,  // The async data you're fetching
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Show error message
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No police stations available.')); // Show no data message
        } else {
          // Data is available
          final policeStations = snapshot.data!;

          return SingleChildScrollView(  // Wrap the Column with SingleChildScrollView
            child: Column(
              children: policeStations.map((station) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('Police Station'),
                    subtitle: Text('Lat: ${station['latitude']}, Lng: ${station['longitude']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.map),
                      onPressed: () async {
                        // Fetch current position from Geolocator
                        Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                        // Pass latitude, longitude, and current position to onMapFunction
                        String latitude = station['latitude']!;
                        String longitude = station['longitude']!;
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
