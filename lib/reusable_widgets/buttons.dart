import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety_framework/reusable_widgets/textStyles.dart';
import 'package:women_safety_framework/utils/color_utils.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Icon? icon;
  final double height;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 45,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child:
        ElevatedButton.icon(
          style: ButtonStyle(
              alignment: Alignment.center,
              iconAlignment: IconAlignment.start,
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.black26;
                }
                return hexStringToColor("#f8f1f9");
              }),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              )
          ),
          onPressed: onPressed,
          icon: icon != null ? icon : SizedBox.shrink(),
          label: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
    );
  }
}

