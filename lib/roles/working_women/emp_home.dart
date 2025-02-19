import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:women_safety_framework/roles/normal_user/home.dart';
import 'package:women_safety_framework/roles/working_women/emp_signin.dart';
import 'package:women_safety_framework/roles/workplace_policies.dart';
import 'package:women_safety_framework/utils/color_utils.dart';

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
    }
  }

  void _addEmergencyContact() {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Emergency Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Contact Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection(collectionType)
                      .doc(widget.userId)
                      .collection('emergency_contacts')
                      .add({
                    'name': nameController.text,
                    'phone': phoneController.text,
                  });
                  await FirebaseFirestore.instance
                      .collection('normal_users')
                      .doc(widget.userId)
                      .collection('emergency_contacts')
                      .add({
                    'name': nameController.text,
                    'phone': phoneController.text,
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EmpSignin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Home"),
        backgroundColor: hexStringToColor("CB2B93"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading:
                      Icon(Icons.business, color: hexStringToColor("5E61F4")),
                  title: const Text("Your Organization"),
                  subtitle: Text(
                    organizationName == null
                        ? "Fetching..."
                        : "$organizationName (${organizationId ?? "Fetching..."})",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Security Team",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
                                color: hexStringToColor("5E61F4")),
                            title: Text(member['name'] ?? 'Unknown'),
                            subtitle: Text(
                                member['phone'] ?? 'No contact information'),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 20),
              const Text(
                "Emergency Contacts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(collectionType)
                    .doc(widget.userId)
                    .collection('emergency_contacts')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No emergency contacts found.");
                  }
                  var contacts = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      var contact = contacts[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.contact_phone,
                              color: hexStringToColor("5E61F4")),
                          title: Text(contact['name'] ?? 'Unknown'),
                          subtitle: Text(contact['phone'] ?? 'No phone number'),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: _addEmergencyContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hexStringToColor("CB2B93"),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Add Emergency Contact",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
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
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      label: Text(
                        "View Workplace Policies",
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hexStringToColor("CB2B93"),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: hexStringToColor("CB2B93"),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: _logout,
          child: const Text("Logout",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
