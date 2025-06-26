import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/Widgets/circle_next_button.dart';

class Step3BirthDate extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Map<String, dynamic> formData;

  const Step3BirthDate({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.formData,
  });

  @override
  State<Step3BirthDate> createState() => _Step3BirthDateState();
}

class _Step3BirthDateState extends State<Step3BirthDate> {
  DateTime? selectedDate;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.formData["birthDate"];
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate =
        selectedDate ?? DateTime(now.year - 18, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: ColorPalette.primary,
              surface: ColorPalette.primary,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: ColorPalette.primary,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _errorText = null;
      });
    }
  }

  void _continue() {
    if (selectedDate != null) {
      widget.formData["birthDate"] = selectedDate;
      widget.onNext();
    } else {
      setState(() {
        _errorText = "Please select your birth date.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        selectedDate != null
            ? DateFormat('dd MMMM yyyy').format(selectedDate!)
            : "Tap to select date";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "When is your birth date?",
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: ColorPalette.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.6),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ),
        const SizedBox(height: 40),
        CircleNextButton(onPressed: _continue),
      ],
    );
  }
}
