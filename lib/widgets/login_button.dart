import 'package:flutter/material.dart';
import 'package:scuba_diving/colors/color_palette.dart';

class LoginButton extends StatelessWidget {
  final double height;
  final VoidCallback? onTap;
  final bool isLoading;

  const LoginButton({
    super.key,
    required this.height,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height * 0.09,
        decoration: BoxDecoration(
          color: ColorPalette.semiTransparentBlack,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: ColorPalette.white, width: 1.0),
        ),
        child: Center(
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                    "Login",
                    style: TextStyle(color: ColorPalette.white, fontSize: 24),
                  ),
        ),
      ),
    );
  }
}
