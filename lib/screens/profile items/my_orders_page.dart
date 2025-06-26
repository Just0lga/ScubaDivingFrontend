import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:scuba_diving/screens/order_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/order.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? _authToken;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchOrders();
  }

  Future<void> _loadUserDataAndFetchOrders() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('userId');
      _authToken = prefs.getString('authToken');

      if (_currentUserId == null || _authToken == null) {
        setState(() {
          _errorMessage = 'User not logged in or authentication token missing.';
          _isLoading = false;
        });
        _showSnackBar(
          'Authentication required. Please log in.',
          ColorPalette.error,
        );
        return;
      }
      await _fetchOrders();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading user data: $e';
        _isLoading = false;
      });
      _showSnackBar('Error loading user data: $e', ColorPalette.error);
    }
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_currentUserId == null || _authToken == null) {
      setState(() {
        _errorMessage = 'User ID or Auth Token is missing after initial check.';
        _isLoading = false;
      });
      return;
    }

    final String apiUrl = '$API_BASE_URL/api/Order/user/$_currentUserId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> orderData = jsonDecode(response.body);
        setState(() {
          _orders = orderData.map((json) => Order.fromJson(json)).toList();
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load orders: ${response.statusCode} - ${response.body}';
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return ColorPalette.success;
      case 'in transit':
        return ColorPalette.primary;
      case 'waiting':
        return ColorPalette.error;
      case 'cancelled':
        return ColorPalette.error;
      default:
        return ColorPalette.error;
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
          'My Orders',
          style: GoogleFonts.poppins(color: ColorPalette.white),
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
              : _orders.isEmpty
              ? Center(
                child: Text(
                  'You have no orders yet.',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: ColorPalette.black70,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: ColorPalette.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OrderDetailsPage(order: order),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order.id}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.black,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      order.status,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      color: _getStatusColor(order.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: ColorPalette.black70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: ColorPalette.black70.withOpacity(0.7),
                              ),
                            ),
                            if (order.updatedAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Last Updated: ${DateFormat('dd/MM/yyyy HH:mm').format(order.updatedAt!)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: ColorPalette.black70.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
