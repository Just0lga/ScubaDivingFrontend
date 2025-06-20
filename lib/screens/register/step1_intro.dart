import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/Widgets/circle_next_button.dart'
    show CircleNextButton;

class Step1Intro extends StatelessWidget {
  final VoidCallback onNext;

  const Step1Intro({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Let's get to know you",
            style: GoogleFonts.poppins(
              fontSize: 24,
              color: ColorPalette.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          CircleNextButton(onPressed: onNext),
        ],
      ),
    );
  }
}
