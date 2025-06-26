import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/screens/main_page.dart';

class OrderConfirmationPage extends StatelessWidget {
  final bool isSuccess;
  final int? orderId;
  final String? errorMessage;

  const OrderConfirmationPage({
    super.key,
    required this.isSuccess,
    this.orderId,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSuccess ? "Order Confirmation" : "Order Error",
          style: GoogleFonts.poppins(color: ColorPalette.white, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: height * 0.1),
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.green : Colors.red,
                size: 100,
              ),
              SizedBox(height: height * 0.03),
              Text(
                isSuccess
                    ? "Your order has been placed successfully!"
                    : "An error occurred while placing your order!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isSuccess ? ColorPalette.black : Colors.red,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isSuccess)
                Text(
                  "Order ID: #${orderId ?? 'N/A'}",
                  style: GoogleFonts.poppins(
                    color: ColorPalette.black70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (!isSuccess && errorMessage != null)
                Text(
                  "Error Detail: ${errorMessage!}",
                  style: GoogleFonts.poppins(
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: height * 0.04),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primary,
                  foregroundColor: ColorPalette.white,
                  padding: EdgeInsets.symmetric(
                    vertical: height * 0.02,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Return to Main Page",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
