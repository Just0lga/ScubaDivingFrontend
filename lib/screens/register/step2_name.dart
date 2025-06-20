import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/Widgets/circle_next_button.dart';

class CustomUnderlineTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final Color color1;
  final Color color2;
  final String? Function(String?)? validator;

  const CustomUnderlineTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    required this.color1,
    required this.color2,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(color: color1),
      cursorColor: color1,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: color2, fontSize: 16),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: color1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: color1, width: 2),
        ),
        errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

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
  // Form durumunu yönetmek için GlobalKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    // Formun geçerliliğini kontrol et
    if (_formKey.currentState?.validate() ?? false) {
      // Validasyon başarılı ise verileri güncelle ve bir sonraki adıma geç
      widget.formData["email"] = emailController.text.trim();
      widget.formData["firstName"] = firstNameController.text.trim();
      widget.formData["lastName"] = lastNameController.text.trim();
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      // Form widget'ı eklendi
      key: _formKey, // GlobalKey atandı
      child: Column(
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
          // UnderlineTextField yerine CustomUnderlineTextFormField kullanıldı
          CustomUnderlineTextFormField(
            label: "Email",
            controller: emailController,
            color1: ColorPalette.white,
            color2: ColorPalette.white70,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email boş bırakılamaz';
              }
              // Basit bir email format kontrolü
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Geçerli bir email adresi girin';
              }
              return null; // Geçerliyse null döndür
            },
          ),
          const SizedBox(height: 20),
          CustomUnderlineTextFormField(
            label: "First Name",
            controller: firstNameController,
            color1: ColorPalette.white,
            color2: ColorPalette.white70,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'İsim boş bırakılamaz';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomUnderlineTextFormField(
            label: "Last Name",
            controller: lastNameController,
            color1: ColorPalette.white,
            color2: ColorPalette.white70,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Soyisim boş bırakılamaz';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          CircleNextButton(onPressed: _continue),
        ],
      ),
    );
  }
}
