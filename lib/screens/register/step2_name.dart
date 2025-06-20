import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/Widgets/circle_next_button.dart';
import 'package:scuba_diving/Widgets/underline_text_field.dart';

class Step2Name extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Map<String, dynamic> formData;

  const Step2Name({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.formData,
  });

  @override
  State<Step2Name> createState() => _Step2NameState();
}

class _Step2NameState extends State<Step2Name> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.formData["email"]);
    firstNameController = TextEditingController(
      text: widget.formData["firstName"],
    );
    lastNameController = TextEditingController(
      text: widget.formData["lastName"],
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _continue() {
    widget.formData["email"] = emailController.text.trim();
    widget.formData["firstName"] = firstNameController.text.trim();
    widget.formData["lastName"] = lastNameController.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "What's your name?",
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: ColorPalette.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        UnderlineTextField(
          label: "Email",
          controller: emailController,
          Color1: ColorPalette.white,
          Color2: ColorPalette.white70,
        ),
        const SizedBox(height: 20),
        UnderlineTextField(
          label: "First Name",
          controller: firstNameController,
          Color1: ColorPalette.white,
          Color2: ColorPalette.white70,
        ),
        const SizedBox(height: 20),
        UnderlineTextField(
          label: "Last Name",
          controller: lastNameController,
          Color1: ColorPalette.white,
          Color2: ColorPalette.white70,
        ),
        const SizedBox(height: 40),
        CircleNextButton(onPressed: _continue),
      ],
    );
  }
}
