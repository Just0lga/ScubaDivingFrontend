import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnderlineTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final Color Color1;
  final Color Color2;

  const UnderlineTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    required this.Color1,
    required this.Color2,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(color: Color1),
      cursorColor: Color1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Color2, fontSize: 16),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color1, width: 2),
        ),
      ),
    );
  }
}
