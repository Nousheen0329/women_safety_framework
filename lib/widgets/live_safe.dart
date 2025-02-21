import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'live_safe/PoliceStationCard.dart'; // Assuming you have this card widget for each location.
import 'live_safe/HospitalCard.dart'; // Assuming you create a similar card widget for hospitals.

class LiveSafe extends StatefulWidget {
  const LiveSafe({Key? key}) : super(key: key);

  @override
  _LiveSafeState createState() => _LiveSafeState();
}

class _LiveSafeState extends State<LiveSafe> {
  List<Widget> policeStations = [];
  List<Widget> hospitals = [];

  // Get current location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied.');
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Location permissions are permanently denied.');
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Find nearby police stations
  Future<void> findNearbyPoliceStations(Position position) async {
    String url = 'https://overpass-api.de/api/interpreter?data=[out:json];node(around:5000,${position.latitude},${position.longitude})[amenity=police];out;';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['elements'].isEmpty) {
          Fluttertoast.showToast(msg: 'No nearby police stations found.');
        } else {
          List<Widget> stations = [];
          for (var element in data['elements']) {
            double lat = element['lat'];
            double lon = element['lon'];
            Position currentPosition = await _getCurrentLocation();

            stations.add(
              PoliceStationCard(
                onMapFunction: openMap,
                policeStationsFuture: Future.value([
                  {'latitude': lat.toString(), 'longitude': lon.toString(),'currentPosition':currentPosition.toString()},
                ]),  // This returns a future that resolves immediately with the list of stations
              ),
            );
          }

          // Update the UI after the layout phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              policeStations = stations;
            });
          });
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to fetch data.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  // Find nearby hospitals
  Future<void> findNearbyHospitals(Position position) async {
    String url = 'https://overpass-api.de/api/interpreter?data=[out:json];node(around:2000,${position.latitude},${position.longitude})[amenity=hospital];out;';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['elements'].isEmpty) {
          Fluttertoast.showToast(msg: 'No nearby hospitals found.');
        } else {
          List<Widget> hospitalList = [];
          for (var element in data['elements']) {
            Position currentPosition = await _getCurrentLocation();
            double lat = element['lat'];
            double lon = element['lon'];

            hospitalList.add(
              HospitalCard(
                onMapFunction: openMap,
                hospitalsFuture: Future.value([
                  {'latitude': lat.toString(), 'longitude': lon.toString(),'currentPosition':currentPosition.toString()},
                ]),  // This returns a future that resolves immediately with the list of hospitals
              ),
            );
          }

          // Update the UI after the layout phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              hospitals = hospitalList;
            });
          });
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to fetch data.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  static Future<void> openMap(String latitude, String longitude, Position currentPosition) async {
    String osmUrl = 'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=16/$latitude/$longitude';

    // OSRM API URL for directions
    String osrmDirectionsUrl =
        'https://router.project-osrm.org/route/v1/driving/${currentPosition.longitude},${currentPosition.latitude};$longitude,$latitude?overview=false&alternatives=false&steps=true';

    print("OSRM Directions URL: $osrmDirectionsUrl");  // Debugging the URL

    try {
      final directionsResponse = await http.get(Uri.parse(osrmDirectionsUrl));

      print("API Response Status: ${directionsResponse.statusCode}");  // Log response status code
      print("API Response Body: ${directionsResponse.body}");  // Log response body

      if (directionsResponse.statusCode == 200) {
        var directionsData = jsonDecode(directionsResponse.body);
        if (directionsData['routes'].isNotEmpty) {
          var steps = directionsData['routes'][0]['legs'][0]['steps'];
          String directionsText = "Directions:\n";
          for (var step in steps) {
            directionsText += step['instruction'] + '\n';
          }

          // Show the directions to the user (via a toast or another UI element)
          Fluttertoast.showToast(msg: directionsText);
        } else {
          Fluttertoast.showToast(msg: 'No route found.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to fetch directions. Status code: ${directionsResponse.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching directions: $e');
      print("Error fetching directions: $e");  // Log the error
    }

    // Open the OSM map with a marker for the location
    String currentLocationMarkerUrl = '&markers=$latitude,$longitude';

    final Uri _url = Uri.parse(osmUrl + currentLocationMarkerUrl);
    try {
      await launchUrl(_url);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not launch map!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                Position position = await _getCurrentLocation();
                findNearbyPoliceStations(position);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/bus-stop.png',
                    height: 32,
                  ),
                  SizedBox(width: 8), // Add some space between the image and text
                  Text('Find Nearby Police Stations'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ...policeStations,

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                Position position = await _getCurrentLocation();
                findNearbyHospitals(position);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/hospital.png',
                    height: 32,
                  ),
                  SizedBox(width: 8), // Add some space between the image and text
                  Text('Find Nearby Hospitals near by'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ...hospitals,
          ],
        ),
      ),
    );
  }
}
