import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/Widgets/circle_next_button.dart';
import 'package:scuba_diving/main.dart';

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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // ignore: unused_field
  bool _isLoading = false;
  String? _errorMessage;

  void _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = "Please fill both fields.");
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }

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
      print("Response: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        widget.onNext();
      } else {
        final body = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              body['message'] ?? "Registration failed. Please try again.";
        });
      }
    } catch (e, stackTrace) {
      print("Register error: $e");
      print("Stacktrace: $stackTrace");
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
    return Column(
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
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: GoogleFonts.poppins(color: Colors.white),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _confirmController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            labelStyle: GoogleFonts.poppins(color: Colors.white),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 40),
        CircleNextButton(onPressed: _register),
      ],
    );
  }
}
