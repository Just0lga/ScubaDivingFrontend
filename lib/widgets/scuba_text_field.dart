import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';

class ScubaTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const ScubaTextField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          label == "Email" ? TextInputType.emailAddress : TextInputType.text,
      obscureText: label == "Password",
      cursorColor: ColorPalette.white,
      cursorHeight: 24,
      cursorWidth: 2,
      autofocus: false,
      maxLines: 1,
      textInputAction:
          label == "Email" ? TextInputAction.next : TextInputAction.done,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: ColorPalette.white,
          fontSize: 16,
        ),
        filled: true,
        fillColor: ColorPalette.semiTransparentWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(color: ColorPalette.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(color: ColorPalette.white),
        ),
      ),
    );
  }
}
