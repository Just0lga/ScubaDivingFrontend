import 'package:flutter/material.dart';

class ColorPalette {
  // Primary color (hex: #045382)
  static const Color primary = Color(0xFF045382);

  // 55% transparent black (approx. 55% opacity = 0x8C)
  static const Color semiTransparentBlack = Color(0x8C000000);

  // 55% transparent white (approx. 40% opacity = 0x66)
  static const Color semiTransparentWhite = Color(0x66FFFFFF);

  // Solid black
  static const Color black = Color(0xFF000000);
  static const Color black70 = Color.fromARGB(126, 0, 0, 0);

  // Solid white
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Colors.white70;

  //card background
  static const Color cardColor = Color.fromARGB(187, 227, 228, 247);

  //error and success
  static const Color error = Color.fromARGB(255, 248, 8, 8);
  static const Color success = Color.fromARGB(255, 55, 215, 1);
}
