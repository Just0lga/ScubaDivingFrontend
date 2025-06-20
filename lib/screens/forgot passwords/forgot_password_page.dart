import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/screens/forgot%20passwords/verify_reset_code_page.dart'; // Ensure this path is correct
import 'package:scuba_diving/widgets/forgot_password_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // For loading state

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Request to send password reset code
  Future<void> _sendResetCodeRequest() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email address.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true; // Start loading state
    });

    final String apiUrl = '$API_BASE_URL/api/Auth/forgot-password';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'email': email}),
      );

      if (response.statusCode == 200) {
        _showSnackBar(
          'A reset code has been sent to your email.',
          Colors.green,
        );
        // Navigate to the code verification page, passing the email
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyResetCodePage(email: email),
          ),
        );
      } else {
        String errorMessage =
            'Password reset request failed: ${response.statusCode}';
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
          "Forgot Password",
          style: GoogleFonts.playfair(
            color: ColorPalette.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorPalette.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          children: [
            Text(
              "Enter your email address to reset your password.",
              textAlign: TextAlign.center,
              style: GoogleFonts.playfair(
                color: ColorPalette.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: height * 0.03),
            ForgotPasswordTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(
                Icons.email,
                color: ColorPalette.black,
              ), // Changed icon color to black for visibility
              hintText: 'example@email.com',
            ),
            SizedBox(height: height * 0.03),
            _isLoading
                ? LoadingAnimationWidget.hexagonDots(
                  color: ColorPalette.primary,
                  size: height * 0.05,
                )
                : ElevatedButton(
                  onPressed: _sendResetCodeRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        ColorPalette.primary, // Button background color
                    foregroundColor: ColorPalette.white, // Button text color
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.015,
                      horizontal: width * 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Send Code To My Mail",
                    style: GoogleFonts.playfair(
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
