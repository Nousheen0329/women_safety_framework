import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // For animation effects
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety_framework/fetchWorkplaceDetails.dart';
import 'package:women_safety_framework/reusable_widgets/buttons.dart';
import 'package:women_safety_framework/reusable_widgets/textStyles.dart';
import 'package:women_safety_framework/roles/normal_user/forum/forum_home.dart';
import 'package:women_safety_framework/roles/normal_user/home.dart';
import 'package:women_safety_framework/utils/color_utils.dart';
import 'package:women_safety_framework/widgets/home_widgets/safewebview.dart';
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
    requestLocationPermission();
    requestSMSPermission();
  }

  void _startBackgroundService() {
    final service = FlutterBackgroundService();
    service.invoke("setAsForeground");
  }

  void navigateToRoute(BuildContext context, Widget route) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => route));
  }

  Future<Position?> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permission denied.");
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location permission permanently denied. Please enable from settings to send location.");
      openAppSettings();
      return null;
    }
  }

  Future<void> requestSMSPermission() async {
    PermissionStatus status = await Permission.sms.status;
    if (status.isDenied) {
      Fluttertoast.showToast(msg: "SMS permission denied.");
      await Permission.sms.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [hexStringToColor('9AA1D9'),
              hexStringToColor('9070BA'),], // Vibrant gradient
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
                        "EmpowerHer",
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

                  SizedBox(height:10),
                  SafeHome(),

                  buildSectionTitle("Emergency Services"),
                  Emergency(),

                  buildSectionTitle("Explore Safe Locations"),
                  LiveSafe(),

                  buildSectionTitle("Chatbot"),
                  InkWell(
                    onTap: () async {
                      final String _gradiourl = "https://208820cd5a0d23b341.gradio.live/";
                      final Uri _url = Uri.parse(_gradiourl);
                      try {
                        await launchUrl(_url);
                      } catch (e) {
                        Fluttertoast.showToast(msg: 'Could not launch map!');
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

                  buildSectionTitle("Document Repository"),// Carousel Section
                  CustomCarousel(),

                  buildSectionTitle("Sign In Options"),

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
}
