import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/product.dart';
import 'package:scuba_diving/models/cart.dart';
import 'package:scuba_diving/models/favorite.dart';
import 'package:scuba_diving/screens/picture/picture.dart';
import 'package:scuba_diving/screens/product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductSearchPage extends StatefulWidget {
  final String initialQuery;
  const ProductSearchPage({super.key, this.initialQuery = ''});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  bool _isLoading = false;
  String _currentQuery = '';

  String? _currentUserId;
  Set<int> _favoriteProductIds = {};
  Set<int> _cartProductIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _currentQuery = widget.initialQuery;

    _loadUserDataAndFavorites();
    _loadUserDataAndCartItems();

    if (_currentQuery.isNotEmpty) {
      _searchProducts(_currentQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndCartItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserCartItems(_currentUserId!);
    }
  }

  Future<void> _fetchUserCartItems(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token not found. Could not fetch cart items.');
      return;
    }

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
        setState(() {
          _cartProductIds =
              cartData.map<int>((item) => item['productId'] as int).toSet();
        });
        print('Cart product IDs fetched successfully: $_cartProductIds');
      } else {
        print(
          'Error fetching cart items: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Network error fetching cart items: $e');
    }
  }

  Future<void> _addOrRemoveCart(int productId) async {
    if (_currentUserId == null) {
      _showSnackBar('Please log in to add to cart.', Colors.orange);
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      _showSnackBar(
        'Session token not found. Please log in again.',
        Colors.orange,
      );
      return;
    }

    final bool isCurrentlyCart = _cartProductIds.contains(productId);

    setState(() {
      if (isCurrentlyCart) {
        _cartProductIds.remove(productId);
      } else {
        _cartProductIds.add(productId);
      }
    });

    try {
      http.Response response;

      if (isCurrentlyCart) {
        final String deleteUrl =
            '$API_BASE_URL/api/CartItem/$_currentUserId/$productId';
        print('Sending DELETE request: $deleteUrl');
        response = await http.delete(
          Uri.parse(deleteUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $authToken',
          },
        );
      } else {
        final String postUrl = '$API_BASE_URL/api/CartItem';
        final cart = Cart(
          userId: _currentUserId!,
          productId: productId,
          quantity: 1,
        );
        final String requestBody = jsonEncode(cart.toJson());
        print('Sending POST request: $postUrl with body: $requestBody');
        response = await http.post(
          Uri.parse(postUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $authToken',
          },
          body: requestBody,
        );
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        _showSnackBar(
          isCurrentlyCart ? 'Removed from cart!' : 'Added to cart!',
          Colors.green,
        );
        print(
          'Cart operation successful: ${response.statusCode} - ${response.body}',
        );
      } else {
        setState(() {
          if (isCurrentlyCart) {
            _cartProductIds.add(productId);
          } else {
            _cartProductIds.remove(productId);
          }
        });
        String errorMessage = 'Cart operation failed: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          print('Error parsing error body: $e');
        }
        _showSnackBar(errorMessage, Colors.red);
        print('Cart API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        if (isCurrentlyCart) {
          _cartProductIds.add(productId);
        } else {
          _cartProductIds.remove(productId);
        }
      });
      _showSnackBar('A network error occurred', Colors.red);
      print('Error sending cart request: $e');
    }
  }

  Future<void> _loadUserDataAndFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserFavorites(_currentUserId!);
    }
  }

  Future<void> _fetchUserFavorites(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token not found. Could not fetch favorites.');
      return;
    }

    final String apiUrl = '$API_BASE_URL/api/Favorites/$userId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> favoriteData = jsonDecode(response.body);
        setState(() {
          _favoriteProductIds =
              favoriteData.map<int>((item) => item['productId'] as int).toSet();
        });
        print(
          'Favorite product IDs fetched successfully: $_favoriteProductIds',
        );
      } else {
        print(
          'Error fetching favorite products: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Network error fetching favorite products: $e');
    }
  }

  Future<void> _addOrRemoveFavorite(int productId) async {
    if (_currentUserId == null) {
      _showSnackBar('Please log in to add to favorites.', Colors.orange);
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      _showSnackBar(
        'Session token not found. Please log in again.',
        Colors.orange,
      );
      return;
    }

    final bool isCurrentlyFavorited = _favoriteProductIds.contains(productId);

    setState(() {
      if (isCurrentlyFavorited) {
        _favoriteProductIds.remove(productId);
      } else {
        _favoriteProductIds.add(productId);
      }
    });

    try {
      http.Response response;

      if (isCurrentlyFavorited) {
        final String deleteUrl =
            '$API_BASE_URL/api/Favorites/$_currentUserId/$productId';
        print('Sending DELETE request: $deleteUrl');
        response = await http.delete(
          Uri.parse(deleteUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $authToken',
          },
        );
      } else {
        final String postUrl = '$API_BASE_URL/api/Favorites';
        final favorite = Favorite(
          userId: _currentUserId!,
          productId: productId,
        );
        final String requestBody = jsonEncode(favorite.toJson());
        print('Sending POST request: $postUrl with body: $requestBody');
        response = await http.post(
          Uri.parse(postUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $authToken',
          },
          body: requestBody,
        );
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        _showSnackBar(
          isCurrentlyFavorited
              ? 'Removed from favorites!'
              : 'Added to favorites!',
          Colors.green,
        );
        print(
          'Favorite operation successful: ${response.statusCode} - ${response.body}',
        );
      } else {
        setState(() {
          if (isCurrentlyFavorited) {
            _favoriteProductIds.add(productId);
          } else {
            _favoriteProductIds.remove(productId);
          }
        });
        String errorMessage =
            'Favorite operation failed: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          print('Error parsing error body: $e');
        }
        _showSnackBar(errorMessage, Colors.red);
        print('Favorite API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        if (isCurrentlyFavorited) {
          _favoriteProductIds.add(productId);
        } else {
          _favoriteProductIds.remove(productId);
        }
      });
      _showSnackBar('A network error occurred', Colors.red);
      print('Error sending favorite request: $e');
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentQuery = query;
      _searchResults = [];
    });

    final String apiUrl =
        '$API_BASE_URL/api/Product/search?searchTerm=${Uri.encodeComponent(query)}&PageNumber=1&PageSize=12';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response.body);
        List<Product> fetchedProducts =
            productsJson.map((json) => Product.fromJson(json)).toList();

        setState(() {
          _searchResults = fetchedProducts;
        });
      } else {
        _showSnackBar(
          'No products found matching your criteria.',
          Colors.green,
        );
        print(
          'Error loading search results: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _showSnackBar('An error occurred', Colors.red);
      print('Error fetching search results: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: GoogleFonts.poppins(color: ColorPalette.black70),
            border: InputBorder.none,
            suffixIcon:
                _isLoading
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingAnimationWidget.hexagonDots(
                          color: ColorPalette.primary,
                          size: height * 0.03,
                        ),
                      ),
                    )
                    : IconButton(
                      icon: Icon(Icons.search, color: ColorPalette.black),
                      onPressed: () {
                        _searchProducts(_searchController.text);
                      },
                    ),
          ),
          style: GoogleFonts.poppins(color: ColorPalette.black, fontSize: 18),
          onSubmitted: (value) {
            _searchProducts(value);
          },
          textInputAction: TextInputAction.search,
        ),
        backgroundColor: Colors.white,
        foregroundColor: ColorPalette.black,
        elevation: 0,
      ),
      body:
          _isLoading && _searchResults.isEmpty && _currentQuery.isNotEmpty
              ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                  color: ColorPalette.primary,
                  size: height * 0.05,
                ),
              )
              : _searchResults.isEmpty &&
                  _currentQuery.isNotEmpty &&
                  !_isLoading
              ? const Center(
                child: Text('No products found matching your criteria.'),
              )
              : _searchResults.isEmpty && _currentQuery.isEmpty && !_isLoading
              ? const Center(child: Text('Enter a keyword to start searching.'))
              : GridView.builder(
                padding: EdgeInsets.all(width * 0.04),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: width * 0.04,
                  mainAxisSpacing: height * 0.02,
                  childAspectRatio: 0.7,
                ),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProductPage(productId: product.id),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: ColorPalette.black,
                          width: 0.2,
                        ),
                        color: ColorPalette.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                                child: Container(
                                  height: height * 0.15,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                  ),
                                  child: Picture(
                                    baseUrl:
                                        "https://scuba-diving-s3-bucket.s3.eu-north-1.amazonaws.com/products",
                                    fileName: "${product.name}-1",
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _favoriteProductIds.contains(product.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      _favoriteProductIds.contains(product.id)
                                          ? Colors.red
                                          : Colors.white,
                                ),
                                onPressed: () {
                                  _addOrRemoveFavorite(product.id);
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 5.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${product.price.toStringAsFixed(2)} \$",
                                  style: GoogleFonts.poppins(
                                    color: ColorPalette.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: height * 0.005),
                                Text(
                                  product.name,
                                  style: GoogleFonts.poppins(
                                    color: ColorPalette.black,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                          _cartProductIds.contains(product.id)
                                              ? ColorPalette.primary
                                              : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            _cartProductIds.contains(product.id)
                                                ? ColorPalette.primary
                                                : Colors.black,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        _cartProductIds.contains(product.id)
                                            ? Icons.shopping_cart
                                            : Icons.shopping_cart_outlined,
                                        color:
                                            _cartProductIds.contains(product.id)
                                                ? Colors.white
                                                : Colors.black,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        _addOrRemoveCart(product.id);
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints.tightFor(
                                        width: 25,
                                        height: 25,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
