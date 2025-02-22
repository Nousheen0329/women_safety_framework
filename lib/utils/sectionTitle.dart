import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildSectionTitle(String text) {
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
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.1,
      ),
    ),
    ),
  );
}

Widget buildSettingItem(IconData icon, String title, String value) {
  return ListTile(
    leading: Icon(icon, color: Colors.white70),
    title: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        shadows: [
          Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 5.0,
            color: Colors.black.withOpacity(0.5),
          ),
        ],
      ),
    ),
    subtitle: Text(
      value,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
    ),
  );
}