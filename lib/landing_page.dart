import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // For animation effects
import 'package:women_safety_framework/fetchWorkplaceDetails.dart';
import 'package:women_safety_framework/reusable_widgets/buttons.dart';
import 'package:women_safety_framework/roles/normal_user/forum/forum_home.dart';
import 'package:women_safety_framework/roles/normal_user/home.dart';
import 'utils/quotes.dart';
import 'widgets/home_widgets/CustomCarousel.dart'; // Fixed typo
import 'widgets/home_widgets/emergency.dart';
import 'widgets/live_safe.dart';
import 'package:women_safety_framework/roles/normal_user/signin.dart';
import 'package:women_safety_framework/roles/organization_admin/admin_signin.dart';
import 'package:women_safety_framework/roles/working_women/emp_signin.dart';
import 'widgets/home_widgets/safehome/SafeHome.dart';
import 'package:women_safety_framework/roles/working_women/emp_home.dart' as HomeScreenWorkingWoman;
import 'package:women_safety_framework/roles/organization_admin/admin_home.dart' as HomeScreenOrganizationAdmin;

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _startBackgroundService();
    fetchAndStoreWorkplaceData();
  }

  void _startBackgroundService() {
    final service = FlutterBackgroundService();
    service.invoke("setAsForeground");
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

                  // Carousel Section
                  CustomCarousel(),

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

                  CustomButton(text:"Sign in to Anonymous Forum", onPressed: () async {
                    String? uid = await _storage.read(key: 'normal_uid');
                    if(uid!=null){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForumScreen()),
                      );
                    }
                    else{
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Signin()),
                      );
                    }
                    }
                  ),

                  CustomButton(text: "Sign in as Working Woman", onPressed: () async {
                  String? uid = await _storage.read(key: 'working_woman_uid');
                  if(uid!=null){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreenWorkingWoman.HomeScreen(userId: uid)),
                    );
                  }
                  else{
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmpSignin()),
                    );
                  }
                  }
                  ),

                  CustomButton(text: "Sign in as Organization Admin", onPressed: () async {
                    String? uid = await _storage.read(key: 'org_admin_uid');
                    if(uid!=null){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreenOrganizationAdmin.HomeScreen(adminId: uid)),
                      );
                    }
                    else{
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminSignin()),
                      );
                    }
                  }
                  ),

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
