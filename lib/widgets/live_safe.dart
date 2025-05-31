import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool isLoading = false;

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

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
    setLoading(true);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['elements'].isEmpty) {
          Fluttertoast.showToast(msg: 'No nearby police stations found.');
        }
        else {
          List<Widget> stations = [];
          for (var element in data['elements']) {
            double lat = element['lat'];
            double lon = element['lon'];
            String name='Police Station';
            if(element['tags']['name']!=null) {
              name = element['tags']['name'];
            }
            Position currentPosition = await _getCurrentLocation();
            stations.add(
              PoliceStationCard(
                onMapFunction: openMap,
                policeStationsFuture: Future.value([
                  {'latitude': lat.toString(), 'longitude': lon.toString(),'name': name, 'currentPosition':currentPosition.toString()},
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
    setLoading(false);
  }

  // Find nearby hospitals
  Future<void> findNearbyHospitals(Position position) async {
    String url = 'https://overpass-api.de/api/interpreter?data=[out:json];node(around:2000,${position.latitude},${position.longitude})[amenity=hospital];out;';
    setLoading(true);
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
            String name = 'Hospital';
            if(element['tags']['name']!=null) {
              name = element['tags']['name'];
            }
            hospitalList.add(
              HospitalCard(
                onMapFunction: openMap,
                hospitalsFuture: Future.value([
                  {'latitude': lat.toString(), 'longitude': lon.toString(),'name': name, 'currentPosition':currentPosition.toString()},
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
    setLoading(false);
  }

  static Future<void> openMap(String latitude, String longitude, Position currentPosition) async {
    String directionsUrl = 'https://www.google.com/maps/dir/${currentPosition.latitude.toString()},${currentPosition.longitude.toString()}/${latitude.toString()},${longitude.toString()}/';
    final Uri _url = Uri.parse(directionsUrl);
    try {
      await launchUrl(_url);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not launch map!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                alignment: Alignment.center,
                minimumSize: Size(MediaQuery.of(context).size.width, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),)
              ),
              onPressed: () async {
                Position position = await _getCurrentLocation();
                findNearbyPoliceStations(position);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/bus-stop.png',
                    height: 30,
                  ),
                  SizedBox(width: 8), // Add some space between the image and text
                  Text('Find Nearby Police Stations',
                    style: GoogleFonts.poppins(
                        fontSize: 14.3,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            SizedBox(height: 20),
            ...policeStations,

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  minimumSize: Size(MediaQuery.of(context).size.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),)
              ),
              onPressed: () async {
                Position position = await _getCurrentLocation();
                findNearbyHospitals(position);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/hospital.png',
                    height: 30,
                  ),
                  SizedBox(width: 8), // Add some space between the image and text
                  Text('Find Nearby Hospitals',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ...hospitals,
          ],
        ),
      ),
    );
  }
}
