import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/screens/login_page.dart';

class Step6Confirmation extends StatefulWidget {
  const Step6Confirmation({super.key});

  @override
  State<Step6Confirmation> createState() => _Step6ConfirmationState();
}

class _Step6ConfirmationState extends State<Step6Confirmation> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const Loginpage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorPalette.primary,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Text(
              "Welcome to",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                color: ColorPalette.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Scuba Living Family!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                color: ColorPalette.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "(A confirmation message has been sent to your email)",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: ColorPalette.white.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
