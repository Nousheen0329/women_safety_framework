import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:women_safety_framework/roles/organization_admin/working_woman_details.dart';
import 'package:women_safety_framework/utils/color_utils.dart';
import 'package:women_safety_framework/roles/organization_admin/admin_signin.dart';

class HomeScreen extends StatefulWidget {
  final String adminId;
  const HomeScreen({Key? key, required this.adminId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? organizationId;
  String? organizationName;

  @override
  void initState() {
    super.initState();
    _fetchOrganizationId();
  }

  Future<void> _fetchOrganizationId() async {
    try {
      var adminDoc = await FirebaseFirestore.instance
          .collection('organization_admin')
          .doc(widget.adminId)
          .get();

      if (adminDoc.exists) {
        setState(() {
          organizationId = adminDoc.data()?['organization_id'];
          organizationName = adminDoc.data()?['organization_name'];
        });
      }
    } catch (e) {
      print("Error fetching organization ID and Name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: hexStringToColor("CB2B93"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, Admin!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading:
                      Icon(Icons.business, color: hexStringToColor("5E61F4")),
                  title: Text("Your Organization"),
                  subtitle: Text(organizationName == null
                      ? "Fetching..."
                      : "${organizationName!} (${organizationId ?? "Fetching..."})"),
                ),
              ),
              SizedBox(height: 20),

              // Working Women List
              Text(
                "Working Women in Your Organization",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              organizationId == null
                  ? Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('working_women')
                          .where('organization_id', isEqualTo: organizationId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text("No working women found.");
                        }

                        var workingWomen = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: workingWomen.length,
                          itemBuilder: (context, index) {
                            var woman = workingWomen[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: hexStringToColor("9546C4"),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person,
                                      color: hexStringToColor("5E61F4")),
                                ),
                                title: Text(
                                  woman['name'] ?? 'Unknown',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  woman['email'] ?? 'No email',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WorkingWomanDetails(
                                          womanId: woman.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: hexStringToColor("CB2B93"),
            padding: EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AdminSignin()));
          },
          child: Text("Logout",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
