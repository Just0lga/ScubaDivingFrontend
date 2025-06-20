import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/Widgets/circle_next_button.dart';
import 'package:scuba_diving/main.dart';

class CustomPasswordFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomPasswordFormField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true, // Password fields are always obscured
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

class Step5Password extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Map<String, dynamic> formData;

  const Step5Password({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.formData,
  });

  @override
  State<Step5Password> createState() => _Step5PasswordState();
}

class _Step5PasswordState extends State<Step5Password> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  void _register() async {
    // Validate individual fields first
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // If any field is invalid, stop here
    }

    // Now, perform cross-field validation (password match)
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password != confirm) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/Auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': widget.formData['email'],
          'userName':
              widget.formData['firstName'] + widget.formData['lastName'],
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        widget.onNext();
      } else {
        final body = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              body['message'] ?? "Registration failed. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Create your password",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              color: ColorPalette.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          CustomPasswordFormField(
            label: "Password",
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password cannot be empty.';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long.';
              }
              if (!value.contains(RegExp(r'[A-Z]'))) {
                return 'Password must contain at least one uppercase letter.';
              }
              if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                return 'Password must contain at least one special character.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomPasswordFormField(
            label: "Confirm Password",
            controller: _confirmController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirm Password cannot be empty.';
              }
              // The password match check is done in _register after all field validations
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 40),
          CircleNextButton(onPressed: _register),
        ],
      ),
    );
  }
}
