import 'package:flutter/material.dart';
import 'package:women_safety_framework/reusable_widgets/reusable_widgets.dart';
import 'package:women_safety_framework/roles/organization_admin/admin_signin.dart';
import 'package:women_safety_framework/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../reusable_widgets/buttons.dart';

class AdminSignup extends StatefulWidget {
  const AdminSignup({super.key});

  @override
  State<AdminSignup> createState() => _AdminSignupState();
}

class _AdminSignupState extends State<AdminSignup> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _employeeIdController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _organizationNameController = TextEditingController();
  TextEditingController _organizationIdController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  Future<void> signUpAdmin() async {
    try {
      // Step 1: Register the Admin in Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailTextController.text.trim(),
        password: _passwordTextController.text.trim(),
      );

      String adminUid = userCredential.user!.uid;

      // Step 2: Store Admin Details in Firestore
      await FirebaseFirestore.instance
          .collection("organization_admin")
          .doc(adminUid)
          .set({
        "admin_uid": adminUid,
        "name": _userNameTextController.text.trim(),
        "employee_id": _employeeIdController.text.trim(),
        "phone_number": _phoneNumberController.text.trim(),
        "organization_name": _organizationNameController.text.trim(),
        "organization_id": _organizationIdController.text.trim(),
        "email": _emailTextController.text.trim(),
        "role": "admin",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Step 3: Store the organization details in the 'organization' collection
      await FirebaseFirestore.instance
          .collection("organization")
          .doc(_organizationIdController.text
              .trim()) // Using organization ID as document ID
          .set({
        "organization_name": _organizationNameController.text.trim(),
        "organization_id": _organizationIdController.text.trim(),
        "admin_uid": adminUid, // Associating the organization with the admin
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("Admin registered successfully!");

      // Step 4: Navigate to Sign In Page after Successful Registration
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AdminSignin()));
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("CB2B93"),
          hexStringToColor("9546C4"),
          hexStringToColor("5E61F4")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Admin Name", Icons.person_outline, false,
                    _userNameTextController),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                    "Employee ID", Icons.badge, false, _employeeIdController),
                const SizedBox(height: 20),
                reusableTextField(
                    "Phone Number", Icons.phone, false, _phoneNumberController),
                const SizedBox(height: 20),
                reusableTextField("Organization Name", Icons.apartment, false,
                    _organizationNameController),
                const SizedBox(height: 20),
                reusableTextField("Organization ID", Icons.business, false,
                    _organizationIdController),
                const SizedBox(height: 20),
                reusableTextField("Email Id", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Password", Icons.lock_outlined, true,
                    _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                CustomButton(text: "Sign Up", onPressed: () async {
                  await signUpAdmin();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
