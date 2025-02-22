import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // For animation effects
import 'widgets/home_widgets/custom_appBar.dart';
import 'utils/quotes.dart';
import 'widgets/home_widgets/CustomCarousel.dart'; // Fixed typo
import 'widgets/home_widgets/emergency.dart';
import 'widgets/live_safe.dart';
import 'widgets/emergency_contacts.dart';
import 'package:women_safety_framework/roles/normal_user/signin.dart';
import 'package:women_safety_framework/roles/organization_admin/admin_signin.dart';
import 'package:women_safety_framework/roles/working_women/emp_signin.dart';
import 'widgets/home_widgets/safehome/SafeHome.dart';
import 'package:women_safety_framework/reusable_widgets/reusable_widgets.dart';
import 'package:women_safety_framework/utils/color_utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int qIndex = 0;

  // Generate a random quote index
  void getRandomQuote() {
    Random random = Random();
    if (sweetSayings.isNotEmpty) {
      setState(() {
        qIndex = random.nextInt(sweetSayings.length);
      });
    } else {
      print("Error: sweetSayings list is empty!");
    }
  }

  @override
  void initState() {
    super.initState();
    getRandomQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3ADAD), Color(0xFFFFFFFF)], // Vibrant gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Animated App Title
                  FadeInDown(
                    duration: Duration(milliseconds: 1000),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "✨ A3 presents EmpowerHer App ✨",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(2, 3),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Quote Section (Uncomment if working)
                  // QuoteCard(
                  //   quoteIndex: qIndex,
                  //   onTap: getRandomQuote,
                  // ),

                  // Carousel Section
                  CustomCarousel(), // Fixed name

                  SizedBox(height: 10),
                  SafeHome(),

                  SizedBox(height: 10),
                  _buildSectionTitle("Emergency"),
                  Emergency(),

                  SizedBox(height: 10),
                  _buildSectionTitle("Explore Livesafe Locations"),
                  LiveSafe(),

                  SizedBox(height: 10),
                  _buildSectionTitle("Sign In Options"),

                  firebaseUIButton(context, "Sign in as Normal User", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signin()),
                    );
                  }),

                  firebaseUIButton(context, "Sign in as Organization Admin", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminSignin()),
                    );
                  }),

                  firebaseUIButton(context, "Sign in as Working Woman", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmpSignin()),
                    );
                  }),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to create stylish section titles
  Widget _buildSectionTitle(String text) {
    return AnimatedDefaultTextStyle(
      duration: Duration(seconds: 2),
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.1,
        shadows: [
          Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 5.0,
            color: Colors.black.withOpacity(0.5),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
