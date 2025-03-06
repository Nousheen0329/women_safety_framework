import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:women_safety_framework/reusable_widgets/reusable_widgets.dart';
import 'package:women_safety_framework/roles/working_women/emp_signin.dart';
import 'package:women_safety_framework/utils/color_utils.dart';

import '../../reusable_widgets/buttons.dart';

class EmpSignup extends StatefulWidget {
  const EmpSignup({super.key});

  @override
  State<EmpSignup> createState() => _EmpSignupState();
}

class _EmpSignupState extends State<EmpSignup> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _employeeIDTextController = TextEditingController();
  TextEditingController _phoneNumberTextController = TextEditingController();
  TextEditingController _EmailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedOrganization;
  String? _selectedOrganizationId;
  List<Map<String, String>> _organizations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrganizations();
  }

  Future<void> _fetchOrganizations() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("organization").get();

      List<Map<String, String>> orgs = querySnapshot.docs.map((doc) {
        return {
          "name": doc["organization_name"].toString(),
          "id": doc.id.toString(),
        };
      }).toList();

      setState(() {
        _organizations = orgs;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching organizations: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpUser() async {
    String email = _EmailTextController.text.trim();
    String password = _passwordTextController.text.trim();

    if (_selectedOrganizationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an organization!")),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Map<String, dynamic> workingWomenData = {
        "name": _userNameTextController.text.trim(),
        "employee_id": _employeeIDTextController.text.trim(),
        "phone_number": _phoneNumberTextController.text.trim(),
        "organization_name": _selectedOrganization,
        "organization_id": _selectedOrganizationId,
        "email": email,
        "uid": userCredential.user!.uid,
        "created_at": FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection("working_women")
          .doc(userCredential.user!.uid)
          .set(workingWomenData);

      Map<String, dynamic> normalUserData = {
        "name": _userNameTextController.text.trim(),
        "email": email,
        "phone_number": _phoneNumberTextController.text.trim(),
        "uid": userCredential.user!.uid,
        "created_at": FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection("normal_users")
          .doc(userCredential.user!.uid)
          .set(normalUserData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmpSignin()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
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
                const SizedBox(height: 20),
                reusableTextField("Employee Name", Icons.person_outline, false,
                    _userNameTextController),
                const SizedBox(height: 20),
                reusableTextField("Employee ID", Icons.badge, false,
                    _employeeIDTextController),
                const SizedBox(height: 20),
                reusableTextField("Phone Number", Icons.phone, false,
                    _phoneNumberTextController),
                const SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withAlpha(50),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        dropdownColor: Colors.grey.shade900.withAlpha(240),
                        style: TextStyle(color: Colors.white),
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                        value: (_selectedOrganizationId != null &&
                                _selectedOrganizationId!.isNotEmpty)
                            ? _selectedOrganizationId
                            : null,
                        isExpanded: true,
                        hint: Text("Select Organization",
                            style: TextStyle(color: Colors.white70)),
                        items: _organizations.map((org) {
                          return DropdownMenuItem<String>(
                            value: org["id"],
                            child: Text("${org["name"]} (${org["id"]})",
                                style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOrganizationId = value;
                            _selectedOrganization = _organizations.firstWhere(
                                (org) => org["id"] == value)["name"];
                          });
                        },
                      ),
                const SizedBox(height: 20),
                reusableTextField("Email ID", Icons.email_outlined, false,
                    _EmailTextController),
                const SizedBox(height: 20),
                reusableTextField("Password", Icons.lock_outlined, true,
                    _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                CustomButton(text: "Sign Up", onPressed: _signUpUser),
              ],
            ),
          ))),
    );
  }
}
