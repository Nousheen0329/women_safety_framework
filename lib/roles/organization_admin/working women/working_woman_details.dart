import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_framework/utils/color_utils.dart';

class WorkingWomanDetails extends StatefulWidget {
  final String womanId;
  const WorkingWomanDetails({Key? key, required this.womanId})
      : super(key: key);

  @override
  _WorkingWomanDetailsState createState() => _WorkingWomanDetailsState();
}

class _WorkingWomanDetailsState extends State<WorkingWomanDetails> {
  Map<String, dynamic>? womanData;

  @override
  void initState() {
    super.initState();
    _fetchWomanDetails();
  }

  Future<void> _fetchWomanDetails() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('working_women')
          .doc(widget.womanId)
          .get();

      if (doc.exists) {
        setState(() {
          womanData = doc.data();
        });
      }
    } catch (e) {
      print("Error fetching woman details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Working Woman Details"),
        backgroundColor: hexStringToColor("CB2B93"),
      ),
      body: womanData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: ListTile(
                      leading:
                          Icon(Icons.person, color: hexStringToColor("5E61F4")),
                      title: Text("Name"),
                      subtitle: Text(womanData!['name'] ?? 'Unknown'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: ListTile(
                      leading:
                          Icon(Icons.email, color: hexStringToColor("5E61F4")),
                      title: Text("Email"),
                      subtitle: Text(womanData!['email'] ?? 'Unknown'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: ListTile(
                      leading:
                          Icon(Icons.phone, color: hexStringToColor("5E61F4")),
                      title: Text("Phone"),
                      subtitle: Text(womanData!['phone_number'] ?? 'Unknown'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: ListTile(
                      leading:
                          Icon(Icons.badge, color: hexStringToColor("5E61F4")),
                      title: Text("Employee ID"),
                      subtitle: Text(womanData!['employee_id'] ?? 'Unknown'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
