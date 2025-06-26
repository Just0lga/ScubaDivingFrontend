import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/screens/forgot%20passwords/verify_reset_code_page.dart';
import 'package:scuba_diving/widgets/forgot_password_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCodeRequest() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email address.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
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
      _showSnackBar('A network error occurred', Colors.red);
      print('Error sending password reset request: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
          style: GoogleFonts.poppins(color: ColorPalette.white),
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
          children: [
            Text(
              "Enter your email address to reset your password.",
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
              prefixIcon: Icon(Icons.email, color: ColorPalette.black),
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
                    "Send Code To My Mail",
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
