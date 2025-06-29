import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';

class TakeInfo extends StatelessWidget {
  const TakeInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: ColorPalette.white),
        title: Text(
          'Scuba Diving Info',
          style: GoogleFonts.poppins(fontSize: 22, color: ColorPalette.white),
        ),
        backgroundColor: ColorPalette.black,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/login_page_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _infoCard(
                  title: 'What is Scuba Diving?',
                  content:
                      'Scuba diving is an underwater diving activity where divers use a self-contained underwater breathing apparatus (SCUBA) to breathe underwater. Unlike snorkeling, scuba divers can stay underwater for longer periods and explore deeper depths.',
                ),
                const SizedBox(height: 20),
                _infoCard(
                  title: 'Why People Love Scuba Diving?',
                  children: [
                    _infoBullet(
                      'Explore beautiful coral reefs and marine life',
                    ),
                    _infoBullet('Experience the feeling of weightlessness'),
                    _infoBullet('Discover shipwrecks and underwater caves'),
                    _infoBullet('Great for adventure, travel, and relaxation'),
                  ],
                ),
                const SizedBox(height: 20),
                _infoCard(
                  title: 'Is Scuba Diving Safe?',
                  content:
                      'Yes! With proper training and certified instructors, scuba diving is a very safe sport. It’s important to follow the guidelines, use good quality equipment, and dive within your limits.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    String? content,
    List<Widget>? children,
  }) {
    return Card(
      color: ColorPalette.cardColor.withOpacity(0.85),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorPalette.primary,
              ),
            ),
            const SizedBox(height: 12),
            if (content != null)
              Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: ColorPalette.black,
                ),
              ),
            if (children != null) ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: ColorPalette.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: ColorPalette.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
