// lib/widgets/credit_cart_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart'; // Make sure this path is correct

/// A custom TextField specifically designed for credit card input fields.
/// It includes specialized formatting for card numbers, expiry dates, and CVVs,
/// as well as the standard TextField properties like labels, controllers, and icons.
class CreditCartTextField extends StatelessWidget {
  /// The label text displayed above the input field.
  final String label;

  /// The controller for the TextField, used to retrieve and set its text.
  final TextEditingController controller;

  /// The type of keyboard to use for editing the text.
  final TextInputType keyboardType;

  /// Whether to hide the text being edited (e.g., for passwords).
  final bool obscureText;

  /// Whether the TextField is read-only.
  final bool readOnly;

  /// An icon to display before the input field.
  final Widget? prefixIcon;

  /// An icon to display after the input field.
  final Widget? suffixIcon;

  /// A callback function to be called when the suffix icon is pressed.
  final VoidCallback? onSuffixIconPressed;

  /// Text that suggests what sort of input the field accepts.
  final String? hintText;

  /// Optional input formatters to apply to the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// The maximum number of characters (for CVV, expiry, etc.).
  final int? maxLength;

  const CreditCartTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.hintText,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      cursorColor: ColorPalette.black, // Dark cursor for visibility
      cursorHeight: 24,
      cursorWidth: 2,
      autofocus: false,
      maxLines: 1,
      textInputAction:
          keyboardType == TextInputType.emailAddress ||
                  label.contains('Card Number')
              ? TextInputAction
                  .next // Move to next field after card number or email
              : TextInputAction.done,
      style: const TextStyle(color: Colors.black), // Input text color
      inputFormatters: inputFormatters,
      maxLength: maxLength, // Apply max length
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) =>
              null, // Hide character counter

      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: GoogleFonts.poppins(
          color: ColorPalette.black, // Dark label text
          fontSize: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          color: ColorPalette.black, // Lighter hint text
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
          borderSide: const BorderSide(
            color: ColorPalette.black,
          ), // Dark border when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            color: ColorPalette.primary,
          ), // Primary color border when focused
        ),
        prefixIcon: prefixIcon,
        suffixIcon:
            suffixIcon != null
                ? IconButton(
                  icon: suffixIcon!,
                  onPressed: onSuffixIconPressed,
                  color: ColorPalette.black, // Dark suffix icon
                )
                : null,
      ),
    );
  }
}

// Custom formatter for credit card expiry date (MM/YY)
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Remove any non-digit characters
    newText = newText.replaceAll(RegExp(r'\D'), '');

    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 2) {
        // Insert '/' after the 2nd digit (MM)
        formattedText += '/';
      }
      formattedText += newText[i];
    }

    // Limit to MM/YY (4 digits + 1 slash = 5 characters)
    if (formattedText.length > 5) {
      formattedText = formattedText.substring(0, 5);
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
