import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/address.dart';
import 'package:scuba_diving/models/product.dart';
import 'package:scuba_diving/screens/login_page.dart';
import 'package:scuba_diving/screens/order_confirmation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scuba_diving/widgets/credit_cart_text_field.dart';

class PaymentPage extends StatefulWidget {
  final List<Product> cartProducts;
  final Map<int, int> cartProductQuantities;
  final double totalAmount;

  const PaymentPage({
    super.key,
    required this.cartProducts,
    required this.cartProductQuantities,
    required this.totalAmount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _currentUserId;
  String? _authToken;
  bool _isLoading = true;
  List<Address> _addresses = [];
  int? _selectedAddressId;

  final TextEditingController _paymentMethodController = TextEditingController(
    text: "Credit Card",
  );
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchAddresses();
  }

  @override
  void dispose() {
    _paymentMethodController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndFetchAddresses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    _authToken = prefs.getString('authToken');

    if (_currentUserId != null && _authToken != null) {
      await _fetchUserAddresses(_currentUserId!, _authToken!);
    } else {
      _showSnackBar('Please log in to proceed with payment.', Colors.orange);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Loginpage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _fetchUserAddresses(String userId, String authToken) async {
    final String apiUrl = '$API_BASE_URL/api/Address/all/$userId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> addressData = jsonDecode(response.body);
        setState(() {
          _addresses =
              addressData.map((json) => Address.fromJson(json)).toList();
          if (_addresses.isNotEmpty) {
            _selectedAddressId =
                _addresses
                    .firstWhere(
                      (address) => address.isDefault,
                      orElse: () => _addresses.first,
                    )
                    .id;
          }
        });
        print('Addresses successfully fetched: ${_addresses.length} items.');
      } else {
        _showSnackBar(
          'Failed to fetch addresses: ${response.statusCode}',
          Colors.red,
        );
        print(
          'Failed to load addresses: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _showSnackBar('A network error occurred: $e', Colors.red);
      print('Error fetching addresses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (_currentUserId == null || _authToken == null) {
      _showSnackBar('You need to be logged in.', Colors.red);
      return;
    }
    if (_selectedAddressId == null) {
      _showSnackBar('Please select a delivery address.', Colors.red);
      return;
    }
    if (widget.cartProducts.isEmpty) {
      _showSnackBar(
        'Your cart is empty, cannot proceed with payment.',
        Colors.red,
      );
      return;
    }
    if (_cardNumberController.text.trim().isEmpty) {
      _showSnackBar('Card Number cannot be empty.', Colors.red);
      return;
    }
    if (_cardNumberController.text.trim().length < 16) {
      _showSnackBar('Please enter a valid 16-digit card number.', Colors.red);
      return;
    }
    if (_expiryDateController.text.trim().isEmpty) {
      _showSnackBar('Expiry Date cannot be empty.', Colors.red);
      return;
    }
    if (!RegExp(
      r'^(0[1-9]|1[0-2])\/?([0-9]{2})$',
    ).hasMatch(_expiryDateController.text.trim())) {
      _showSnackBar('Please enter a valid expiry date (MM/YY).', Colors.red);
      return;
    }
    if (_cvvController.text.trim().isEmpty) {
      _showSnackBar('CVV cannot be empty.', Colors.red);
      return;
    }
    if (_cvvController.text.trim().length != 3) {
      _showSnackBar('Please enter a valid 3-digit CVV.', Colors.red);
      return;
    }
    if (_cardHolderNameController.text.trim().isEmpty) {
      _showSnackBar('Card Holder Name cannot be empty.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int? orderId;

      final orderApiUrl = '$API_BASE_URL/api/Order';
      final orderBody = jsonEncode({
        'userId': _currentUserId,
        'shippingAddressId': _selectedAddressId,
        'totalAmount': widget.totalAmount,
      });
      print('Order POST request to: $orderApiUrl with body: $orderBody');
      final orderResponse = await http.post(
        Uri.parse(orderApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
        body: orderBody,
      );

      if (orderResponse.statusCode == 200 || orderResponse.statusCode == 201) {
        final orderData = jsonDecode(orderResponse.body);
        orderId = orderData['id'] as int?;
        if (orderId == null) {
          throw Exception('Order created but orderId not received.');
        }
        _showSnackBar('Order successfully created.', Colors.green);
      } else {
        throw Exception(
          'Failed to create order: ${orderResponse.statusCode} - ${orderResponse.body}',
        );
      }

      for (var product in widget.cartProducts) {
        final orderItemApiUrl = '$API_BASE_URL/api/OrderItem';
        final orderItemBody = jsonEncode({
          'orderId': orderId,
          'productId': product.id,
          'name': product.name,
          'quantity': widget.cartProductQuantities[product.id] ?? 1,
          'price': product.price,
        });
        print(
          'OrderItem POST request to: $orderItemApiUrl with body: $orderItemBody',
        );
        final orderItemResponse = await http.post(
          Uri.parse(orderItemApiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $_authToken',
          },
          body: orderItemBody,
        );

        if (orderItemResponse.statusCode != 200 &&
            orderItemResponse.statusCode != 201) {
          throw Exception(
            'Failed to create order item (${product.name}): ${orderItemResponse.statusCode} - ${orderItemResponse.body}',
          );
        }
      }
      _showSnackBar('Order items successfully added.', Colors.green);

      final paymentApiUrl = '$API_BASE_URL/api/Payment';
      final paymentBody = jsonEncode({
        'userId': _currentUserId,
        'orderId': orderId,
        'amount': widget.totalAmount,
        'method': _paymentMethodController.text.trim(),
        'status': 'Completed',
        'transactionId': 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      });
      print('Payment POST request to: $paymentApiUrl with body: $paymentBody');
      final paymentResponse = await http.post(
        Uri.parse(paymentApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
        body: paymentBody,
      );

      if (paymentResponse.statusCode == 200 ||
          paymentResponse.statusCode == 201) {
        _showSnackBar('Payment successfully recorded!', Colors.green);
      } else {
        throw Exception(
          'Failed to record payment: ${paymentResponse.statusCode} - ${paymentResponse.body}',
        );
      }

      for (var product in widget.cartProducts) {
        final deleteCartItemUrl =
            '$API_BASE_URL/api/CartItem/$_currentUserId/${product.id}';
        await http.delete(
          Uri.parse(deleteCartItemUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $_authToken',
          },
        );
      }
      print('Cart items cleared from backend.');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  OrderConfirmationPage(isSuccess: true, orderId: orderId!),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('An error occurred during payment process: $e');
      _showSnackBar('Payment failed: ${e.toString()}', Colors.red);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) => OrderConfirmationPage(
                isSuccess: false,
                errorMessage: e.toString(),
              ),
        ),
        (Route<dynamic> route) => false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment",
          style: GoogleFonts.poppins(
            color: ColorPalette.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorPalette.white),
      ),
      body:
          _isLoading
              ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                  color: ColorPalette.primary,
                  size: height * 0.05,
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Delivery Address:",
                      style: GoogleFonts.poppins(
                        color: ColorPalette.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    _addresses.isEmpty
                        ? Text(
                          'No registered addresses found. Please add an address.',
                          style: GoogleFonts.poppins(color: Colors.red),
                        )
                        : DropdownButtonFormField<int>(
                          value: _selectedAddressId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Select Address',
                            labelStyle: GoogleFonts.poppins(
                              color: ColorPalette.black70,
                            ),
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: ColorPalette.primary,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorPalette.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          items:
                              _addresses.map((Address address) {
                                return DropdownMenuItem<int>(
                                  value: address.id,
                                  child: Text(
                                    '${address.title} - ${address.fullAddress}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: ColorPalette.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedAddressId = newValue;
                            });
                          },
                          style: GoogleFonts.poppins(
                            color: ColorPalette.black,
                            fontSize: 16,
                          ),
                          dropdownColor: ColorPalette.cardColor,
                        ),
                    SizedBox(height: height * 0.03),
                    Text(
                      "Cart Summary:",
                      style: GoogleFonts.poppins(
                        color: ColorPalette.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.cartProducts.length,
                      itemBuilder: (context, index) {
                        final product = widget.cartProducts[index];
                        final quantity =
                            widget.cartProductQuantities[product.id] ?? 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${product.name} x$quantity',
                                  style: GoogleFonts.poppins(
                                    color: ColorPalette.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${(product.price * quantity).toStringAsFixed(2)} \$',
                                style: GoogleFonts.poppins(
                                  color: ColorPalette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount:",
                            style: GoogleFonts.poppins(
                              color: ColorPalette.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.totalAmount.toStringAsFixed(2)} \$',
                            style: GoogleFonts.poppins(
                              color: ColorPalette.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Text(
                      "Payment Information:",
                      style: GoogleFonts.poppins(
                        color: ColorPalette.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    CreditCartTextField(
                      label: 'Card Number',
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(
                        Icons.credit_card,
                        color: ColorPalette.black,
                      ),
                      hintText: 'XXXX XXXX XXXX XXXX',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      maxLength: 16,
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      children: [
                        Expanded(
                          child: CreditCartTextField(
                            label: 'Expiry Date (MM/YY)',
                            controller: _expiryDateController,
                            keyboardType: TextInputType.datetime,
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: ColorPalette.black,
                            ),
                            hintText: 'MM/YY',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ExpiryDateFormatter(),
                            ],
                            maxLength: 5,
                          ),
                        ),
                        SizedBox(width: width * 0.04),
                        Expanded(
                          child: CreditCartTextField(
                            label: 'CVV',
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            prefixIcon: Icon(
                              Icons.security,
                              color: ColorPalette.black,
                            ),
                            hintText: 'XXX',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            maxLength: 3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    CreditCartTextField(
                      label: 'Card Holder Name',
                      controller: _cardHolderNameController,
                      keyboardType: TextInputType.text,
                      prefixIcon: Icon(Icons.person, color: ColorPalette.black),
                      hintText: 'First Name Last Name',
                    ),
                    SizedBox(height: height * 0.03),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primary,
                          foregroundColor: ColorPalette.white,
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.02,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Complete Payment",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                  ],
                ),
              ),
    );
  }
}
