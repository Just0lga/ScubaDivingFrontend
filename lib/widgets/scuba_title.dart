import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScubaTitle extends StatelessWidget {
  const ScubaTitle({super.key, required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Scuba Living",
          style: GoogleFonts.poppins(color: color, fontSize: 50, height: 1.1),
        ),
        Text(
          "Life Begins Below the Surface",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: color, fontSize: 15),
        ),
      ],
    );
  }
}
