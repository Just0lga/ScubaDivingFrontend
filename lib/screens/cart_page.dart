import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/Widgets/scuba_title.dart';
import 'package:scuba_diving/screens/payment_page.dart';
import 'package:scuba_diving/screens/picture/picture.dart';
import 'package:scuba_diving/screens/product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scuba_diving/models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scuba_diving/main.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<int, int> _cartProductQuantities = {};
  List<Product> _cartProducts = [];
  bool _isLoadingCartItems = true;
  String? _currentUserId;
  String? _authToken;

  bool showTextField = false;
  final TextEditingController _promotionCodeController =
      TextEditingController();

  bool showTextField2 = false;
  final TextEditingController _giftCardMessageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchCartItems();
  }

  @override
  void dispose() {
    _promotionCodeController.dispose();
    _giftCardMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndFetchCartItems() async {
    setState(() {
      _isLoadingCartItems = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    _authToken = prefs.getString('authToken');

    if (_currentUserId != null && _authToken != null) {
      await _fetchUserCartItems(_currentUserId!, _authToken!);
    } else {
      _showSnackBar('Please log in to view cart items.', Colors.orange);
      setState(() {
        _isLoadingCartItems = false;
      });
    }
  }

  Future<void> _fetchUserCartItems(String userId, String authToken) async {
    final String apiUrl = '$API_BASE_URL/api/CartItem/$userId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> cartData = jsonDecode(response.body);
        Map<int, int> fetchedProductQuantities = {};
        List<Product> fetchedCartProducts = [];

        for (var item in cartData) {
          final int productId = item['productId'] as int;
          fetchedProductQuantities[productId] = item['quantity'] as int? ?? 1;

          final String productDetailApiUrl =
              '$API_BASE_URL/api/Product/$productId';
          try {
            final productResponse = await http.get(
              Uri.parse(productDetailApiUrl),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $authToken',
              },
            );

            if (productResponse.statusCode == 200) {
              final Map<String, dynamic> productJson = jsonDecode(
                productResponse.body,
              );
              fetchedCartProducts.add(Product.fromJson(productJson));
            } else {
              _showSnackBar(
                'Some cart product details could not be fetched.',
                Colors.orange,
              );
            }
          } catch (e) {
            _showSnackBar(
              'An error occurred while fetching some cart product details.',
              Colors.red,
            );
          }
        }
        setState(() {
          _cartProductQuantities = fetchedProductQuantities;
          _cartProducts = fetchedCartProducts;
        });
      } else {
        _showSnackBar('Your cart is empty', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Check WI-FI', Colors.red);
    } finally {
      setState(() {
        _isLoadingCartItems = false;
      });
    }
  }

  Future<void> _removeCartItem(int productId) async {
    if (_currentUserId == null || _authToken == null) {
      _showSnackBar('You need to be logged in.', Colors.orange);
      return;
    }

    final Product? productToRemove = _cartProducts.firstWhere(
      (p) => p.id == productId,
    );

    if (productToRemove == null) {
      _showSnackBar('Product not found in cart.', Colors.red);
      return;
    }

    final int originalQuantity = _cartProductQuantities[productId] ?? 1;
    setState(() {
      _cartProducts.remove(productToRemove);
      _cartProductQuantities.remove(productId);
    });

    try {
      final String deleteUrl =
          '$API_BASE_URL/api/CartItem/$_currentUserId/$productId';
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSnackBar('Product removed from cart!', Colors.green);
      } else {
        String errorMessage =
            'Failed to remove from cart: ${response.statusCode}';
        dynamic errorBody;
        try {
          errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ??
              errorBody['detail'] ??
              errorBody.toString() ??
              errorMessage;
        } catch (e) {
          errorMessage =
              'Failed to remove from cart: ${response.statusCode}. Response body could not be parsed: ${response.body}';
        }
        _showSnackBar(errorMessage, Colors.red);
        setState(() {
          _cartProducts.add(productToRemove);
          _cartProductQuantities[productId] = originalQuantity;
        });
      }
    } catch (e) {
      _showSnackBar('A network error occurred', Colors.red);
      setState(() {
        _cartProducts.add(productToRemove);
        _cartProductQuantities[productId] = originalQuantity;
      });
    }
  }

  Future<void> _updateCartItemQuantity(int productId, int newQuantity) async {
    if (_currentUserId == null || _authToken == null) {
      _showSnackBar('You need to be logged in.', Colors.orange);
      return;
    }

    if (newQuantity < 1) {
      await _removeCartItem(productId);
      return;
    }

    final int? oldQuantity = _cartProductQuantities[productId];

    setState(() {
      _cartProductQuantities[productId] = newQuantity;
    });

    final String apiUrl =
        '$API_BASE_URL/api/CartItem/$_currentUserId/$productId';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({'quantity': newQuantity}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSnackBar('Quantity updated!', Colors.green);
      } else {
        String errorMessage =
            'Failed to update quantity: ${response.statusCode}';
        dynamic errorBody;
        try {
          errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ??
              errorBody['detail'] ??
              errorBody.toString() ??
              errorMessage;
        } catch (e) {
          errorMessage =
              'Failed to update quantity: ${response.statusCode}. Response body could not be parsed: ${response.body}';
        }
        _showSnackBar(errorMessage, Colors.red);
        setState(() {
          if (oldQuantity != null) {
            _cartProductQuantities[productId] = oldQuantity;
          }
        });
      }
    } catch (e) {
      _showSnackBar('A network error occurred', Colors.red);
      setState(() {
        if (oldQuantity != null) {
          _cartProductQuantities[productId] = oldQuantity;
        }
      });
    }
  }

  double _calculateTotalPrice() {
    double total = 0.0;
    for (Product product in _cartProducts) {
      total += product.price * (_cartProductQuantities[product.id] ?? 1);
    }
    return total;
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ColorPalette.black,
          title: Text(
            "Cart",
            style: GoogleFonts.poppins(color: ColorPalette.white, fontSize: 24),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _isLoadingCartItems
                  ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: LoadingAnimationWidget.hexagonDots(
                        color: ColorPalette.primary,
                        size: height * 0.05,
                      ),
                    ),
                  )
                  : _cartProducts.isEmpty && _currentUserId != null
                  ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Your cart is empty.',
                      style: GoogleFonts.poppins(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cartProducts.length,
                    itemBuilder: (context, index) {
                      final product = _cartProducts[index];
                      final quantity = _cartProductQuantities[product.id] ?? 1;
                      final imagePath = product.mainPictureUrl;

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductPage(
                                        productId: _cartProducts[index].id,
                                      ),
                                ),
                              );
                            },

                            child: Container(
                              color: ColorPalette.white,
                              height: height * 0.15,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: width * 0.25,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Picture(
                                      baseUrl:
                                          "https://scuba-diving-s3-bucket.s3.eu-north-1.amazonaws.com/products",
                                      fileName: "${product.name}-1",
                                    ),
                                  ),
                                  SizedBox(width: width * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: GoogleFonts.poppins(
                                                  color: ColorPalette.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed:
                                                  () => _removeCartItem(
                                                    product.id,
                                                  ),
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: ColorPalette.black,
                                                size: 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${product.price * quantity} \$",
                                          style: GoogleFonts.poppins(
                                            color: ColorPalette.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            width: width * 0.3,
                                            height: height * 0.035,
                                            decoration: BoxDecoration(
                                              color: ColorPalette.black,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                  onTap:
                                                      () =>
                                                          _updateCartItemQuantity(
                                                            product.id,
                                                            quantity - 1,
                                                          ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: ColorPalette.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                Text(
                                                  quantity.toString(),
                                                  style: GoogleFonts.poppins(
                                                    color: ColorPalette.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap:
                                                      () =>
                                                          _updateCartItemQuantity(
                                                            product.id,
                                                            quantity + 1,
                                                          ),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: ColorPalette.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Container(
                            color: ColorPalette.black,
                            height: 0.3,
                            width: width,
                          ),
                        ],
                      );
                    },
                  ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => setState(() => showTextField = !showTextField),
                  child: Row(
                    children: [
                      Checkbox(
                        value: showTextField,
                        checkColor: ColorPalette.white,
                        activeColor: Colors.black,
                        onChanged:
                            (val) => setState(() => showTextField = val!),
                      ),
                      Text(
                        "I want to use promotion code",
                        style: GoogleFonts.poppins(
                          color: ColorPalette.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showTextField)
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: width * 0.4,
                    bottom: height * 0.02,
                  ),
                  child: TextField(
                    controller: _promotionCodeController,
                    cursorColor: Colors.black,
                    style: GoogleFonts.poppins(
                      color: ColorPalette.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: "Enter your code",
                      labelStyle: GoogleFonts.poppins(
                        color: ColorPalette.black,
                        fontSize: 16,
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              Container(color: ColorPalette.black, height: 0.3, width: width),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => setState(() => showTextField2 = !showTextField2),
                  child: Row(
                    children: [
                      Checkbox(
                        value: showTextField2,
                        checkColor: ColorPalette.white,
                        activeColor: Colors.black,
                        onChanged:
                            (val) => setState(() => showTextField2 = val!),
                      ),
                      Text(
                        "I want to add gift card",
                        style: GoogleFonts.poppins(
                          color: ColorPalette.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showTextField2)
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: width * 0.4,
                    bottom: height * 0.02,
                  ),
                  child: TextField(
                    controller: _giftCardMessageController,
                    cursorColor: Colors.black,
                    style: GoogleFonts.poppins(
                      color: ColorPalette.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: "Enter your words for gift card",
                      labelStyle: GoogleFonts.poppins(
                        color: ColorPalette.black,
                        fontSize: 16,
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              Container(color: ColorPalette.black, height: 0.3, width: width),
              SizedBox(height: height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Price",
                          style: GoogleFonts.poppins(
                            color: ColorPalette.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${_calculateTotalPrice().toStringAsFixed(2)} \$",
                          style: GoogleFonts.poppins(
                            color: ColorPalette.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: width * 0.3),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PaymentPage(
                                cartProducts: _cartProducts,
                                cartProductQuantities: _cartProductQuantities,
                                totalAmount: _calculateTotalPrice(),
                              ),
                        ),
                      );
                    },
                    child: Container(
                      width: width * 0.3,
                      height: height * 0.05,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorPalette.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Pay Now",
                        style: GoogleFonts.poppins(
                          color: ColorPalette.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.04),
              ScubaTitle(color: ColorPalette.black),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  const CartItem({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.quantity,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  final double width;
  final double height;
  final String title;
  final double price;
  final String imagePath;
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorPalette.cardColor,
      height: height * 0.15,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.25,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.poppins(
                          color: ColorPalette.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: Icon(
                        Icons.delete_outline,
                        color: ColorPalette.black,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                Text(
                  "$price \$",
                  style: GoogleFonts.poppins(
                    color: ColorPalette.black,
                    fontSize: 16,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: width * 0.3,
                    height: height * 0.035,
                    decoration: BoxDecoration(
                      color: ColorPalette.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: onDecrease,
                          child: Icon(
                            Icons.remove,
                            color: ColorPalette.white,
                            size: 20,
                          ),
                        ),
                        Text(
                          quantity.toString(),
                          style: GoogleFonts.poppins(
                            color: ColorPalette.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: onIncrease,
                          child: Icon(
                            Icons.add,
                            color: ColorPalette.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
