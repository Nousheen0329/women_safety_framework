import 'package:flutter/material.dart';
import 'package:women_safety_framework/roles/normal_user/signin.dart';
import 'package:women_safety_framework/roles/organization_admin/admin_signin.dart';
import 'package:women_safety_framework/roles/working_women/emp_signin.dart';
import 'package:women_safety_framework/reusable_widgets/reusable_widgets.dart';
import 'package:women_safety_framework/utils/color_utils.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  logoWidget("assets/images/logo1.png"),
                  const SizedBox(height: 30),
                  firebaseUIButton(context, "Sign in as Normal User", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Signin()));
                  }),
                  const SizedBox(height: 20),
                  firebaseUIButton(context, "Sign in as Organization Admin",
                      () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AdminSignin()));
                  }),
                  const SizedBox(height: 20),
                  firebaseUIButton(context, "Sign in as Working Woman", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EmpSignin()));
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
