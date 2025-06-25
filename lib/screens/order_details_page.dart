import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:scuba_diving/screens/product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için

import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart'; // API_BASE_URL için
import 'package:scuba_diving/models/order.dart'; // Order modelini import edin
import 'package:scuba_diving/models/order_item.dart'; // Yeni OrderItem modelini import edin

class OrderDetailsPage extends StatefulWidget {
  final Order order; // MyOrdersPage'ten gelecek olan sipariş objesi

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  List<OrderItem> _orderItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthTokenAndFetchOrderItems();
  }

  Future<void> _loadAuthTokenAndFetchOrderItems() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('authToken');

      if (_authToken == null) {
        setState(() {
          _errorMessage = 'Authentication token missing. Please log in.';
          _isLoading = false;
        });
        _showSnackBar(
          'Authentication required. Please log in.',
          ColorPalette.error,
        );
        return;
      }
      await _fetchOrderItems();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading authentication data: $e';
        _isLoading = false;
      });
      _showSnackBar(
        'Error loading authentication data: $e',
        ColorPalette.error,
      );
    }
  }

  Future<void> _fetchOrderItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_authToken == null) {
      setState(() {
        _errorMessage = 'Auth Token is missing. Cannot fetch order items.';
        _isLoading = false;
      });
      return;
    }

    final String apiUrl =
        '$API_BASE_URL/api/OrderItem/byOrder/${widget.order.id}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> itemData = jsonDecode(response.body);
        setState(() {
          _orderItems =
              itemData.map((json) => OrderItem.fromJson(json)).toList();
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'No items found for this order.';
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load order items: ${response.statusCode} - ${response.body}';
        });
        _showSnackBar(_errorMessage, ColorPalette.error);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error or invalid response: $e';
      });
      _showSnackBar('Network error: $e', ColorPalette.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.order.id} Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: ColorPalette.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorPalette.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: ColorPalette.primary),
              )
              : _errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: ColorPalette.error,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Status: ${widget.order.status.toUpperCase()}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Amount: \$${widget.order.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: ColorPalette.black70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order Date: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.order.createdAt)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: ColorPalette.black70.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Order Items:',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        _orderItems.isEmpty
                            ? Center(
                              child: Text(
                                'No items found for this order.',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: ColorPalette.black70,
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              itemCount: _orderItems.length,
                              itemBuilder: (context, index) {
                                final item = _orderItems[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                ProductPage(productId: item.id),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 10.0),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    color: ColorPalette.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: ColorPalette.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Quantity: ${item.quantity}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: ColorPalette.black70,
                                                  ),
                                                ),
                                                Text(
                                                  'Price: \$${item.price.toStringAsFixed(2)} each',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: ColorPalette.black70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: ColorPalette.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
