import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/screens/forgot%20passwords/forgot_password_page.dart';
import 'package:scuba_diving/screens/register/register_page.dart';
import 'package:scuba_diving/screens/main_page.dart';
import 'package:scuba_diving/Widgets/scuba_text_field.dart';
import 'package:scuba_diving/Widgets/scuba_title.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Yeni import

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = emailController.text;
    final password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // JWT token'ı al
        final String? token = responseData['token'] as String?;

        if (token != null && token.isNotEmpty) {
          // JWT token'ı ayrıştır
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

          // userId'yi 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier' claim'inden al
          // Bu claim genellikle kullanıcının benzersiz ID'sini temsil eder.
          final String? userId =
              decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
                  as String?;

          if (userId != null && userId.isNotEmpty) {
            await prefs.setString('userId', userId);
            print('userId Shared Preferences\'a kaydedildi: $userId');

            // Token'ı da kaydetmek isteyebilirsiniz, API'ye yapacağınız yetkili istekler için kullanılabilir.
            await prefs.setString('authToken', token);
            print('Auth Token Shared Preferences\'a kaydedildi.');
          } else {
            print(
              'Uyarı: JWT içindeki userId (nameidentifier claim) bulunamadı veya boştu.',
            );
            _errorMessage =
                'Kullanıcı ID bilgisi alınamadı.'; // Kullanıcıya gösterilecek hata
          }
        } else {
          print('Uyarı: Response body\'sinde JWT token bulunamadı veya boştu.');
          _errorMessage =
              'Giriş token\'ı alınamadı.'; // Kullanıcıya gösterilecek hata
        }

        if (_errorMessage == null) {
          // Eğer bir hata oluşmadıysa yönlendir
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        }
      } else {
        String message = 'Giriş başarısız';
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (e) {
          print('Uyarı: Response body JSON olarak ayrıştırılamadı: $e');
        }
        setState(() {
          _errorMessage = message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('images/login_page_background.jpg', fit: BoxFit.cover),
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(width * 0.05),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScubaTitle(color: ColorPalette.white),
                            SizedBox(height: height * 0.05),
                            ScubaTextField(
                              label: "Email",
                              controller: emailController,
                            ),
                            SizedBox(height: height * 0.02),
                            ScubaTextField(
                              label: "Password",
                              controller: passwordController,
                            ),
                            if (_errorMessage != null) ...[
                              SizedBox(height: height * 0.02),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            SizedBox(height: height * 0.05),
                            GestureDetector(
                              onTap: _isLoading ? null : _login,
                              child: Container(
                                height: height * 0.09,
                                decoration: BoxDecoration(
                                  color: ColorPalette.semiTransparentBlack,
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: ColorPalette.white,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child:
                                      _isLoading
                                          ? LoadingAnimationWidget.hexagonDots(
                                            color: Colors.white,
                                            size: height * 0.05,
                                          )
                                          : Text(
                                            "Login",
                                            style: TextStyle(
                                              color: ColorPalette.white,
                                              fontSize: 24,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            _buildFooterTexts(height),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterTexts(double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: Text(
                "Still not a user? Click here.",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ColorPalette.white),
              ),
            ),
            SizedBox(height: height * 0.005),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
              child: Text(
                "Forgot Password?",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ColorPalette.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
