import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/favorite.dart';
import 'package:scuba_diving/models/product.dart';
import 'package:scuba_diving/screens/picture/picture.dart';
import 'package:scuba_diving/screens/product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchFavorites();
  }

  Future<void> _loadUserDataAndFetchFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    _authToken = prefs.getString('authToken');

    if (_currentUserId != null && _authToken != null) {
      await _fetchFavoriteProducts(_currentUserId!);
    } else {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Please log in to view favorite products.', Colors.orange);
    }
  }

  Future<void> _fetchFavoriteProducts(String userId) async {
    if (_authToken == null) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(
        'Session token not found. Please log in again.',
        Colors.orange,
      );
      return;
    }

    final String favoritesApiUrl = '$API_BASE_URL/api/Favorites/$userId';

    try {
      final response = await http.get(
        Uri.parse(favoritesApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> favoriteJsonList = jsonDecode(response.body);

        List<Product> fetchedProducts = [];
        for (var favoriteJson in favoriteJsonList) {
          final Favorite favorite = Favorite.fromJson(favoriteJson);
          final int productId = favorite.productId;

          final String productDetailApiUrl =
              '$API_BASE_URL/api/Product/$productId';

          try {
            final productResponse = await http.get(
              Uri.parse(productDetailApiUrl),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-F8',
                'Authorization': 'Bearer $_authToken',
              },
            );

            if (productResponse.statusCode == 200) {
              final Map<String, dynamic> productJson = jsonDecode(
                productResponse.body,
              );
              fetchedProducts.add(Product.fromJson(productJson));
            } else {
              _showSnackBar(
                'Some favorite product details could not be fetched.',
                Colors.orange,
              );
            }
          } catch (e) {
            _showSnackBar(
              'An error occurred while fetching some favorite product details.',
              Colors.red,
            );
          }
        }

        setState(() {
          _favoriteProducts = fetchedProducts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Your favorites are empty.', Colors.green);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Check WI-FI', Colors.red);
    }
  }

  Future<void> _removeFavorite(int productId) async {
    if (_currentUserId == null || _authToken == null) {
      _showSnackBar('Please log in to remove from favorites.', Colors.orange);
      return;
    }

    final Product? removedProduct = _favoriteProducts.firstWhere(
      (product) => product.id == productId,
    );

    if (removedProduct != null) {
      setState(() {
        _favoriteProducts.removeWhere((product) => product.id == productId);
      });
      _showSnackBar('Removing from favorites...', Colors.grey);
    } else {
      return;
    }

    try {
      final String deleteUrl =
          '$API_BASE_URL/api/Favorites/$_currentUserId/$productId';
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSnackBar('Removed from favorites successfully!', Colors.green);
      } else {
        if (removedProduct != null) {
          setState(() {
            _favoriteProducts.add(removedProduct);
          });
          _favoriteProducts.sort((a, b) => a.id.compareTo(b.id));
        }
        await _fetchFavoriteProducts(_currentUserId!);
        String errorMessage =
            'Failed to remove from favorites: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ?? errorBody['detail'] ?? errorMessage;
        } catch (e) {}
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      if (removedProduct != null) {
        setState(() {
          _favoriteProducts.add(removedProduct);
          _favoriteProducts.sort((a, b) => a.id.compareTo(b.id));
        });
      }
      await _fetchFavoriteProducts(_currentUserId!);
      _showSnackBar('A network error occurred', Colors.red);
    }
  }

  Future<void> _addToCart(Product product) async {
    if (_currentUserId == null || _authToken == null) {
      _showSnackBar('Please log in to add the product to cart.', Colors.orange);
      return;
    }

    _showSnackBar('${product.name} is being added to cart...', Colors.grey);

    final String apiUrl = '$API_BASE_URL/api/CartItem';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'userId': _currentUserId,
          'productId': product.id,
          'quantity': 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('"${product.name}" added to cart!', Colors.green);
      } else {
        String errorMessage = "The product is already in cart";
        print("Failed to add to cart: ${response.statusCode}");
        dynamic errorBody;
        try {
          errorBody = jsonDecode(response.body);
          print(response.body);
        } catch (e) {}
        _showSnackBar(errorMessage, Colors.green);
      }
    } catch (e) {
      _showSnackBar('A network error occurred', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
            "Favorites",
            style: GoogleFonts.poppins(color: ColorPalette.white, fontSize: 24),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child:
              _isLoading
                  ? Center(
                    child: LoadingAnimationWidget.hexagonDots(
                      color: ColorPalette.primary,
                      size: height * 0.05,
                    ),
                  )
                  : _favoriteProducts.isEmpty
                  ? Center(
                    child: Text(
                      _currentUserId == null
                          ? 'Please log in to see favorite products.'
                          : 'You have no favorite products yet.',
                      style: GoogleFonts.poppins(
                        color: ColorPalette.black,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _favoriteProducts.length,
                          itemBuilder: (context, index) {
                            final product = _favoriteProducts[index];
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProductPage(
                                              productId:
                                                  _favoriteProducts[index].id,
                                            ),
                                      ),
                                    );
                                  },
                                  child: FavoriteProductItem(
                                    width: width,
                                    height: height,
                                    product: product,
                                    onRemove: () => _removeFavorite(product.id),
                                    onAddToCart: () => _addToCart(product),
                                    imagePath: product.mainPictureUrl,
                                  ),
                                ),
                                Container(
                                  color: ColorPalette.black,
                                  height: 0.2,
                                  width: width,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class FavoriteProductItem extends StatelessWidget {
  const FavoriteProductItem({
    super.key,
    required this.width,
    required this.height,
    required this.product,
    required this.onRemove,
    required this.imagePath,
    required this.onAddToCart,
  });

  final double width;
  final double height;
  final Product product;
  final VoidCallback onRemove;
  final String imagePath;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * 0.15,
      color: Colors.white,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              width: width * 0.3,
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
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
                      ),
                    ),
                  ],
                ),
                Text(
                  "${product.price.toStringAsFixed(2)} \$",
                  style: GoogleFonts.poppins(
                    color: ColorPalette.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 2),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: width * 0.3,
                          height: height * 0.04,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorPalette.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Add to Cart",
                            style: GoogleFonts.poppins(
                              color: ColorPalette.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
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
