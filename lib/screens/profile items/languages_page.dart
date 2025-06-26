import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';

class LanguagesPage extends StatefulWidget {
  const LanguagesPage({super.key});

  @override
  State<LanguagesPage> createState() => _LanguagesPageState();
}

class _LanguagesPageState extends State<LanguagesPage> {
  String _selectedLanguage = 'English';

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected language: $language'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Languages",
          style: GoogleFonts.poppins(color: ColorPalette.white, fontSize: 24),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorPalette.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select your preferred language:",
              style: GoogleFonts.poppins(
                color: ColorPalette.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.02),
            ListTile(
              title: Text(
                "English",
                style: GoogleFonts.poppins(
                  color: ColorPalette.black,
                  fontSize: 16,
                ),
              ),
              trailing:
                  _selectedLanguage == 'English'
                      ? Icon(Icons.check_circle, color: ColorPalette.primary)
                      : null,
              onTap: () {
                _selectLanguage('English');
              },
            ),
            Divider(),

            SizedBox(height: height * 0.02),
            Text(
              "Sorry, we are working on adding new languages to the app.",
              style: GoogleFonts.poppins(
                color: ColorPalette.black70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
