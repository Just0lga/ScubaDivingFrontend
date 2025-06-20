import 'package:flutter/material.dart';
import 'package:scuba_diving/colors/color_palette.dart';

class CircleNextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CircleNextButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: ColorPalette.primary,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white, width: 20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: const CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: Icon(Icons.arrow_forward, color: ColorPalette.primary, size: 30),
      ),
    );
  }
}
