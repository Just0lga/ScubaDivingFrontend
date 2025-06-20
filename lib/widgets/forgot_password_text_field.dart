import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';

class ForgotPasswordTextField extends StatelessWidget {
  /// The label text displayed above the input field.
  final String label;

  /// The controller for the TextField, used to retrieve and set its text.
  final TextEditingController controller;

  /// The type of keyboard to use for editing the text. Defaults to [TextInputType.text].
  final TextInputType keyboardType;

  /// Whether to hide the text being edited (e.g., for passwords). Defaults to `false`.
  final bool obscureText;

  /// Whether the TextField is read-only. Defaults to `false`.
  final bool readOnly;

  /// An icon to display before the input field.
  final Widget? prefixIcon;

  /// An icon to display after the input field.
  final Widget? suffixIcon;

  /// A callback function to be called when the suffix icon is pressed.
  final VoidCallback? onSuffixIconPressed;

  /// Text that suggests what sort of input the field accepts.
  final String? hintText;

  const ForgotPasswordTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text, // Default to text
    this.obscureText = false, // Default to not obscure
    this.readOnly = false, // Default to not read-only
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      cursorColor: ColorPalette.black,
      cursorHeight: 24,
      cursorWidth: 2,
      autofocus: false,
      maxLines: 1,
      textInputAction:
          keyboardType == TextInputType.emailAddress
              ? TextInputAction.next
              : TextInputAction.done,
      style: const TextStyle(color: Colors.black), // Input text color
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: GoogleFonts.poppins(
          color: ColorPalette.black,
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
          borderSide: const BorderSide(color: ColorPalette.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(color: ColorPalette.black),
        ),
        prefixIcon: prefixIcon,
        suffixIcon:
            suffixIcon != null
                ? IconButton(
                  icon: suffixIcon!,
                  onPressed: onSuffixIconPressed,
                  color: ColorPalette.black,
                )
                : null,
      ),
    );
  }
}
