import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart'; // For API_BASE_URL
import 'package:scuba_diving/screens/login_page.dart'; // For navigating to LoginPage
import 'package:scuba_diving/widgets/forgot_password_text_field.dart';

class VerifyResetCodePage extends StatefulWidget {
  final String email; // Email address passed from the Forgot Password page

  const VerifyResetCodePage({super.key, required this.email});

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false; // For loading state
  bool _isPasswordVisible = false; // For password visibility toggle

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email; // Auto-fill email address
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Request to verify the reset code and set a new password
  Future<void> _verifyAndResetPassword() async {
    final String email = _emailController.text.trim();
    final String code = _codeController.text.trim();
    final String newPassword = _newPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email address.', Colors.red);
      return;
    }
    if (code.isEmpty) {
      _showSnackBar('Please enter the verification code.', Colors.red);
      return;
    }
    if (newPassword.isEmpty || newPassword.length < 6) {
      _showSnackBar('Password must be at least 6 characters long.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true; // Start loading state
    });

    final String apiUrl = '$API_BASE_URL/api/Auth/verify-reset-code';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar(
          'Your password has been successfully reset. You can now log in.',
          Colors.green,
        );
        // Navigate to LoginPage on success
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder:
                (context) => const Loginpage(), // Adjust with your LoginPage
          ),
          (Route<dynamic> route) => false, // Clear all previous routes
        );
      } else {
        String errorMessage = 'Password reset failed: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          print('Error parsing error body: $e');
        }
        _showSnackBar(errorMessage, Colors.red);
        print('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showSnackBar('A network error occurred: $e', Colors.red);
      print('Error sending password reset request: $e');
    } finally {
      setState(() {
        _isLoading = false; // End loading state
      });
    }
  }

  // Method to show a SnackBar notification to the user
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reset Password",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: ColorPalette.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorPalette.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the code sent to your email and your new password.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: ColorPalette.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: height * 0.03),
            ForgotPasswordTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              prefixIcon: const Icon(Icons.email, color: ColorPalette.black),
              hintText: 'example@email.com',
            ),
            SizedBox(height: height * 0.02),
            ForgotPasswordTextField(
              label: 'Verification Code',
              controller: _codeController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.vpn_key, color: ColorPalette.black),
              hintText: 'Enter the code sent to you',
            ),
            SizedBox(height: height * 0.02),
            ForgotPasswordTextField(
              label: 'New Password',
              controller: _newPasswordController,
              obscureText: !_isPasswordVisible,
              hintText: 'At least 6 characters',
              prefixIcon: const Icon(Icons.lock, color: ColorPalette.black),
              suffixIcon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: ColorPalette.black,
              ),
              onSuffixIconPressed: () {
                setState(() {
                  _isPasswordVisible =
                      !_isPasswordVisible; // Toggle password visibility
                });
              },
            ),
            SizedBox(height: height * 0.03),
            _isLoading
                ? LoadingAnimationWidget.hexagonDots(
                  color: ColorPalette.primary,
                  size: height * 0.05,
                )
                : ElevatedButton(
                  onPressed: _verifyAndResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primary,
                    foregroundColor: ColorPalette.white,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.015,
                      horizontal: width * 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Reset Password",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
