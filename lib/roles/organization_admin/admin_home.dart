import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:women_safety_framework/reusable_widgets/buttons.dart';
import 'package:women_safety_framework/reusable_widgets/textStyles.dart';
import 'package:women_safety_framework/roles/organization_admin/reports/admin_reports_list.dart';
import 'package:women_safety_framework/roles/organization_admin/working%20women/working_women_list.dart';
import 'package:women_safety_framework/roles/workplace_policies.dart';
import 'package:women_safety_framework/utils/color_utils.dart';
import 'package:women_safety_framework/roles/organization_admin/admin_signin.dart';

import '../secureStorageService.dart';
import 'editGeofencingOrganization.dart';

class HomeScreen extends StatefulWidget {
  final String adminId;
  const HomeScreen({Key? key, required this.adminId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? organizationId;
  String? organizationName;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrganizationDetails();
  }

  Future<void> _fetchOrganizationDetails() async {
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
      print("Error fetching organization details: $e");
    }
  }

  Future<void> _uploadWorkplacePolicy() async {
    try {
      if (organizationId == null || organizationId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization ID not available!')),
        );
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null ||
          result.files.isEmpty ||
          result.files.first.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected!')),
        );
        return;
      }

      PlatformFile file = result.files.first;
      final String fileName = file.name;

      String documentId = _firestore.collection('organization').doc().id;

      await supabase.storage.from('workplace_policies').uploadBinary(
            fileName,
            file.bytes!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );

      final String fileUrl =
          supabase.storage.from('workplace_policies').getPublicUrl(fileName);

      await _firestore
          .collection('organization')
          .doc(organizationId)
          .collection('workplace_policies')
          .doc(documentId)
          .set({
        'name': fileName,
        'pdfUrl': fileUrl,
        'filePath': fileName,
        'uploadedBy': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Uploaded Successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload Failed: $e')),
      );
    }
  }

  void _deleteContact(String contactId) async {
    try {
      await FirebaseFirestore.instance
          .collection('organization')
          .doc(organizationId)
          .collection('security_team')
          .doc(contactId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete contact')),
      );
    }
  }

  void _addEmergencyContact() {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Emergency Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Contact Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (organizationId != null &&
                    nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('organization')
                      .doc(organizationId)
                      .collection('security_team')
                      .add({
                    'name': nameController.text,
                    'phone': phoneController.text,
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
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
            onPressed: () async {
              await SecureStorageService().clearUserData("org_admin_uid");
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AdminSignin()));
            },
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
              child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildSectionTitle('Organization Details'),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading:
                      Icon(Icons.business),
                  title: const Text("Your Organization"),
                  subtitle: Text(organizationName == null
                      ? "Fetching..."
                      : "${organizationName!} (${organizationId ?? "Fetching..."})"),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading:
                    Icon(Icons.supervised_user_circle),
                    title: Text(organizationName == null
                        ? "Fetching..."
                        : "View Employees"),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WorkingWomenList(organizationId: organizationId!),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading:
                    Icon(Icons.crisis_alert),
                    title: Text(organizationName == null
                        ? "Fetching..."
                        : "View Reports"),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminReportsList(adminOrgId: organizationId!),
                        ),
                      );
                    },
                  ),
                ),
              ),

              buildSectionTitle("Workplace Policies"),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(text: "View Workplace Policies", onPressed: () {
                  if (organizationId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkplacePolicies(
                          organizationId: organizationId!,
                          isAdmin: true,
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
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: isUploading ? null : _uploadWorkplacePolicy,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        isUploading
                            ? "Uploading..."
                            : "Upload Workplace Policies",
                      ),
                      style: ElevatedButton.styleFrom(
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
              SizedBox(height: 10),
              buildSectionTitle('Emergency Contacts'),
              organizationId == null
                  ? Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('organization')
                          .doc(organizationId)
                          .collection('security_team')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text("No emergency contacts found.");
                        }

                        var contacts = snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            var contact = contacts[index];
                            var contactId = contact.id;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.contact_phone,
                                    color: hexStringToColor("5E61F4")),
                                title: Text(contact['name'] ?? 'Unknown'),
                                subtitle:
                                    Text(contact['phone'] ?? 'No phone number'),
                                trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed:  () => _deleteContact(contactId),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
              SizedBox(height: 10),
              CustomButton(text: "Add Emergency Contact", onPressed: _addEmergencyContact),
              buildSectionTitle('Geofence Settings'),
              SizedBox(height:10),
              organizationId == null || organizationId!.isEmpty
              ? Center(child: CircularProgressIndicator())
              : GeofencingWidgetOrganization(organizationId: organizationId),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}
