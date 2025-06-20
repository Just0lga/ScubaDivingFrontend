import 'package:flutter/material.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/screens/register/step1_intro.dart';
import 'package:scuba_diving/screens/register/step2_name.dart';
import 'package:scuba_diving/screens/register/step3_birthdate.dart';
import 'package:scuba_diving/screens/register/step4_experience.dart';
import 'package:scuba_diving/screens/register/step6_confirmation.dart';
import 'package:scuba_diving/screens/register/step5_password.dart';
import 'package:scuba_diving/Widgets/back_button_circle.dart';
import 'package:scuba_diving/Widgets/step_indicator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _currentStep = 0;

  final Map<String, dynamic> _formData = {
    "email": "",
    "firstName": "",
    "lastName": "",
    "birthDate": null,
    "experienceYears": "",
    "password": "",
    "confirmPassword": "",
  };

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submit() {
    print(_formData);
    setState(() => _currentStep++);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> steps = [
      Step1Intro(onNext: _nextStep),
      Step2Name(onNext: _nextStep, onBack: _prevStep, formData: _formData),
      Step3BirthDate(onNext: _nextStep, onBack: _prevStep, formData: _formData),
      Step4Experience(
        onNext: _nextStep,
        onBack: _prevStep,
        formData: _formData,
      ),
      Step5Password(onNext: _submit, onBack: _prevStep, formData: _formData),
      const Step6Confirmation(),
    ];

    return Scaffold(
      backgroundColor: ColorPalette.primary,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: steps[_currentStep],
          ),
          if (_currentStep > 0 && _currentStep < 5)
            Positioned(
              top: 40,
              left: 20,
              child: BackButtonCircle(onTap: _prevStep),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: StepIndicator(currentStep: _currentStep),
          ),
        ],
      ),
    );
  }
}
