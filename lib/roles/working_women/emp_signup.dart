import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:women_safety_framework/reusable_widgets/reusable_widgets.dart';
import 'package:women_safety_framework/roles/working_women/emp_signin.dart';
import 'package:women_safety_framework/utils/color_utils.dart';

class EmpSignup extends StatefulWidget {
  const EmpSignup({super.key});

  @override
  State<EmpSignup> createState() => _EmpSignupState();
}

class _EmpSignupState extends State<EmpSignup> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _employeeIDTextController = TextEditingController();
  TextEditingController _phoneNumberTextController = TextEditingController();
  TextEditingController _organizationNameTextController =
      TextEditingController();
  TextEditingController _organizationIDTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signUpUser() async {
    String email = _emailTextController.text.trim();
    String password = _passwordTextController.text.trim();
    String orgId = _organizationIDTextController.text.trim();
    String orgName = _organizationNameTextController.text.trim();

    try {
      DocumentSnapshot orgSnapshot =
          await _firestore.collection("organization").doc(orgId).get();

      if (!orgSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Organization ID does not exist!")),
        );
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Map<String, dynamic> workingWomenData = {
        "name": _userNameTextController.text.trim(),
        "employee_id": _employeeIDTextController.text.trim(),
        "phone_number": _phoneNumberTextController.text.trim(),
        "organization_name": orgName,
        "organization_id": orgId,
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
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Employee Name", Icons.person_outline, false,
                    _userNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Employee ID", Icons.badge, false,
                    _employeeIDTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Phone Number", Icons.phone, false,
                    _phoneNumberTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Organization Name", Icons.business, false,
                    _organizationNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Organization ID", Icons.confirmation_number,
                    false, _organizationIDTextController),
                const SizedBox(
                  height: 20,
                ),
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
                firebaseUIButton(context, "Sign Up", _signUpUser),
              ],
            ),
          ))),
    );
  }
}
