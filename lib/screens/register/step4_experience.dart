import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:flutter/services.dart';
import 'package:scuba_diving/Widgets/circle_next_button.dart';

class Step4Experience extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Map<String, dynamic> formData;

  const Step4Experience({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.formData,
  });

  @override
  State<Step4Experience> createState() => _Step4ExperienceState();
}

class _Step4ExperienceState extends State<Step4Experience> {
  late TextEditingController _experienceController;

  @override
  void initState() {
    super.initState();
    _experienceController = TextEditingController(
      text: widget.formData["experienceYears"] ?? "",
    );
  }

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  void _continue() {
    final experience = _experienceController.text.trim();
    if (experience.isNotEmpty) {
      widget.formData["experienceYears"] = experience;
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "How many years of experience do you have?",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: ColorPalette.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _experienceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: "e.g. 3",
            hintStyle: GoogleFonts.poppins(color: Colors.white70),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 40),
        CircleNextButton(onPressed: _continue),
      ],
    );
  }
}
