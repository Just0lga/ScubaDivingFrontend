import 'package:flutter/material.dart';

class BackButtonCircle extends StatelessWidget {
  final VoidCallback onTap;

  const BackButtonCircle({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
    );
  }
}
