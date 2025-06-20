import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInfoPage extends StatelessWidget {
  // Your contact information
  final String name = 'Tolga Küçükaşçı';
  final String email = 'tkucukasci@gmail.com';
  final String phoneNumber = '+905396453204';
  final String linkedinUrl = 'https://www.linkedin.com/in/tkucukasci';
  final String githubUrl = 'https://github.com/Just0lga';

  const ContactInfoPage({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Me',
          style: GoogleFonts.playfair(
            color: ColorPalette.white,
            fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Name
            Text(
              name,
              style: GoogleFonts.playfair(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ColorPalette.black,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Flutter Developer | Scuba Diver', // Your title/tagline
              style: GoogleFonts.playfair(
                fontSize: 18,
                color: ColorPalette.black70,
              ),
            ),
            const SizedBox(height: 32),

            // Contact Information Cards
            _buildContactCard(
              context,
              icon: Icons.email,
              label: 'Email',
              value: email,
              onTap:
                  () =>
                      _launchUrl('mailto:$email?subject=Contact%20from%20App'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context,
              icon: Icons.phone,
              label: 'Phone',
              value: phoneNumber,
              onTap: () => _launchUrl('tel:$phoneNumber'),
            ),
            const SizedBox(height: 32),

            // Social Media Links
            Text(
              'Find me on social media:',
              style: GoogleFonts.playfair(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorPalette.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialMediaIcon(
                  context,
                  icon: FontAwesomeIcons.linkedin,
                  url: linkedinUrl,
                  color: const Color(0xFF0A66C2), // LinkedIn blue
                ),
                const SizedBox(width: 24),
                _buildSocialMediaIcon(
                  context,
                  icon: FontAwesomeIcons.github,
                  url: githubUrl,
                  color: const Color(0xFF333333), // GitHub black
                ),
                // Add more social media icons as needed
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Looking forward to connecting!',
              style: GoogleFonts.playfair(
                fontSize: 16,
                color: ColorPalette.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      color: ColorPalette.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Row(
            children: [
              Icon(icon, color: ColorPalette.black, size: 28),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.playfair(
                      fontSize: 14,
                      color: ColorPalette.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.playfair(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaIcon(
    BuildContext context, {
    required IconData icon,
    required String url,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorPalette.cardColor, // Lighter background for the icon
          shape: BoxShape.circle,
        ),
        child: FaIcon(icon, color: color, size: 30),
      ),
    );
  }
}
