import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety_framework/reusable_widgets/buttons.dart';
import 'package:women_safety_framework/reusable_widgets/textStyles.dart';
import 'package:women_safety_framework/roles/normal_user/home.dart';
import 'package:women_safety_framework/roles/working_women/report/report_details.dart';
import 'package:women_safety_framework/roles/working_women/emp_signin.dart';
import 'package:women_safety_framework/roles/working_women/report/report_list.dart';
import 'package:women_safety_framework/roles/workplace_policies.dart';
import 'package:women_safety_framework/utils/color_utils.dart';

import '../secureStorageService.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String collectionType = "working_women";
  String? organizationName;
  String? organizationId;
  double _geofenceRadius = 0;
  double _geofenceLatitude = 0;
  double _geofenceLongitude = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrganizationDetails();
  }

  Future<void> _fetchOrganizationDetails() async {
    var userDoc = await FirebaseFirestore.instance
        .collection(collectionType)
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      setState(() {
        organizationId = userDoc.data()?['organization_id'];
        organizationName = userDoc.data()?['organization_name'];
      });
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('organization')
          .doc(organizationId)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> geofenceData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _geofenceLatitude = geofenceData["latitude"] ?? 0.0;
          _geofenceLongitude = geofenceData["longitude"] ?? 0.0;
          _geofenceRadius = geofenceData["radius"] ?? 0.0;
        });
      }
    }
  }

  void _logout() async {
    await SecureStorageService().clearUserData("working_woman_uid");
    await SecureStorageService().clearUserData("workplace_emergency_contacts");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EmpSignin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors:[
        hexStringToColor('9AA1D9'),
        hexStringToColor('9070BA'),
        ], // Vibrant gradient
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        ),
        ),
        child: SafeArea(
            child:SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildSectionTitle("Organization Details"),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading:
                        Icon(Icons.business, color: Colors.deepPurple),
                    title: const Text("Your Organization"),
                    subtitle: Text(
                      organizationName == null
                          ? "Fetching..."
                          : "$organizationName (${organizationId ?? "Fetching..."})",
                    ),
                  ),
                ),
                SizedBox(height:10),
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
                buildSectionTitle("Security Team"),
                if (organizationId != null)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('organization')
                        .doc(organizationId)
                        .collection('security_team')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text("No security team members found.");
                      }
                      var securityTeam = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: securityTeam.length,
                        itemBuilder: (context, index) {
                          var member = securityTeam[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.security,
                                  color: Colors.deepPurple),
                              title: Text(member['name'] ?? 'Unknown'),
                              subtitle: Text(
                                  member['phone'] ?? 'No contact information'),
                            ),
                          );
                        },
                      );
                    },
                  ),

                buildSectionTitle("Organization Safety"),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading:
                    Icon(Icons.crisis_alert,color: Colors.deepPurple),
                    title: Text("Add Harassment Report"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ReportDetails(userId: widget.userId)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading:
                    Icon(Icons.list_alt, color: Colors.deepPurple),
                    title: Text("View Report Status"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportList(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                ),

                buildSectionTitle("Organization Policies"),
                CustomButton(text: "View Workplace Policies", onPressed: () {
                  if (organizationId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkplacePolicies(
                          organizationId: organizationId!,
                          isAdmin: false,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text('Organization ID not available!')),
                    );
                  }
                },
                  icon: const Icon(Icons.visibility),
                ),
                InkWell(
                  onTap: () async {
                    final String _gradiourl = "https://208820cd5a0d23b341.gradio.live/";
                    final Uri _url = Uri.parse(_gradiourl);
                    try {
                      await launchUrl(_url);
                    } catch (e) {
                      Fluttertoast.showToast(msg: 'Could not launch!');
                    }
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                  "Ask Questions to Chatbot",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  )
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset('assets/chatbot.jpg', fit: BoxFit.contain, height: 150, ),
                          ),
                        ],
                      ),
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
