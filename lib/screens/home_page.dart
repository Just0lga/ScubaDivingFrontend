import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/Widgets/underline_text_field.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/cart.dart' show Cart;
import 'package:scuba_diving/models/favorite.dart';
import 'package:scuba_diving/models/product.dart';
import 'package:scuba_diving/screens/most_favorited_products_page.dart';
import 'package:scuba_diving/screens/picture/picture.dart';
import 'package:scuba_diving/screens/product_page.dart';
import 'package:scuba_diving/screens/product_search_page.dart';
import 'package:scuba_diving/screens/special_offers.dart';
import 'package:scuba_diving/screens/take_info.dart';
import 'package:scuba_diving/screens/top_viewed_products_page.dart';
import 'package:scuba_diving/screens/which_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _mostFavoriteProducts = [];
  List<Product> _topViewedProducts = [];

  bool _isLoadingMostFavorites = false;
  bool _isLoadingTopViewed = false;

  final TextEditingController _searchFieldController = TextEditingController();

  Set<int> _favoriteProductIds = {};
  Set<int> _cartProductIds = {};
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchMostFavoriteProducts();
    _fetchTopViewedProducts();
    _loadUserDataAndFavorites();
    _loadUserDataAndCartItems();
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
      print('Auth Token not found. Cart items could not be fetched.');
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
        print('Cart product IDs successfully fetched: $_cartProductIds');
      } else {
        print(
          'Failed to fetch cart items: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Network error occurred while fetching cart items: $e');
    }
  }

  Future<void> _fetchUserFavorites(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token not found. Favorites could not be fetched.');
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
          'Favorite product IDs successfully fetched: $_favoriteProductIds',
        );
      } else {
        print(
          'Failed to fetch favorite products: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Network error occurred while fetching favorite products: $e');
    }
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  Future<void> _fetchMostFavoriteProducts() async {
    if (_isLoadingMostFavorites) return;

    setState(() {
      _isLoadingMostFavorites = true;
    });

    String apiUrl1 =
        '$API_BASE_URL/api/Product/most-favorited-paged?PageNumber=1&PageSize=4';

    try {
      final response1 = await http.get(Uri.parse(apiUrl1));

      if (response1.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response1.body);
        List<Product> fetchedProducts =
            productsJson.map((json) => Product.fromJson(json)).toList();

        setState(() {
          _mostFavoriteProducts = fetchedProducts;
        });
      } else {
        _showSnackBar(
          'Failed to fetch featured products: ${response1.statusCode}',
          Colors.red,
        );
        print(
          'Failed to load featured products: ${response1.statusCode} - ${response1.body}',
        );
      }
    } catch (e) {
      _showSnackBar('An error occurred', Colors.red);
      print("An error occurred: $e");
      print('Error fetching featured products: $e');
    } finally {
      setState(() {
        _isLoadingMostFavorites = false;
      });
    }
  }

  Future<void> _fetchTopViewedProducts() async {
    if (_isLoadingTopViewed) return;

    setState(() {
      _isLoadingTopViewed = true;
    });

    String apiUrl2 =
        '$API_BASE_URL/api/Product/top-viewed-paged?PageNumber=1&PageSize=4';

    try {
      final response2 = await http.get(Uri.parse(apiUrl2));

      if (response2.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response2.body);
        List<Product> fetchedProducts2 =
            productsJson.map((json) => Product.fromJson(json)).toList();

        setState(() {
          _topViewedProducts = fetchedProducts2;
        });
      } else {
        _showSnackBar(
          'Failed to fetch most viewed products: ${response2.statusCode}',
          Colors.red,
        );
        print(
          'Failed to load most viewed products: ${response2.statusCode} - ${response2.body}',
        );
      }
    } catch (e) {
      _showSnackBar('An error occurred', Colors.red);
      print("An error occurred: $e");

      print('Error fetching most viewed products: $e');
    } finally {
      setState(() {
        _isLoadingTopViewed = false;
      });
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
        print('Sending DELETE request to: $deleteUrl');
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
        print('Sending POST request to: $postUrl with body: $requestBody');
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
          'Cart operation success: ${response.statusCode} - ${response.body}',
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
        print('Sending DELETE request to: $deleteUrl');
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
        print('Sending POST request to: $postUrl with body: $requestBody');
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
          'Favorite operation success: ${response.statusCode} - ${response.body}',
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.04,
            ),
            child: Column(
              children: [
                Text(
                  "Scuba Living",
                  style: GoogleFonts.poppins(
                    color: ColorPalette.black,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: height * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductSearchPage(
                              initialQuery: _searchFieldController.text,
                            ),
                      ),
                    );
                  },
                  child: AbsorbPointer(
                    child: UnderlineTextField(
                      label: 'Search for products',
                      controller: _searchFieldController,
                      obscureText: false,
                      Color1: ColorPalette.black,
                      Color2: ColorPalette.black70,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmallPicture(
                      width: width,
                      height: height,
                      image: 'images/swimming.jpg',
                      text: 'Swimming',
                    ),
                    SmallPicture(
                      width: width,
                      height: height,
                      image: 'images/freediving.jpg',
                      text: 'Spearfishing',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Favorite Products",
                      style: GoogleFonts.poppins(
                        color: ColorPalette.black,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const MostFavoritedProductsPage(),
                          ),
                        );
                      },
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          color: ColorPalette.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: height * 0.23,
                  child:
                      _isLoadingMostFavorites
                          ? Center(
                            child: LoadingAnimationWidget.hexagonDots(
                              color: ColorPalette.primary,
                              size: height * 0.05,
                            ),
                          )
                          : _mostFavoriteProducts.isEmpty &&
                              !_isLoadingMostFavorites
                          ? const Center(child: Text('Products not found.'))
                          : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _mostFavoriteProducts.length,
                            separatorBuilder:
                                (context, index) =>
                                    SizedBox(width: width * 0.02),
                            itemBuilder: (context, index) {
                              final product = _mostFavoriteProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ProductPage(
                                            productId: product.id,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: width * 0.35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: ColorPalette.black,
                                      width: 0.2,
                                    ),
                                    color: ColorPalette.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        alignment: Alignment.topLeft,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(7),
                                                  topRight: Radius.circular(7),
                                                ),
                                            child: Container(
                                              width: width * 0.35,
                                              height: height * 0.15,
                                              color: Colors.transparent,
                                              alignment: Alignment.center,
                                              child: Picture(
                                                baseUrl:
                                                    "https://scuba-diving-s3-bucket.s3.eu-north-1.amazonaws.com/products",
                                                fileName: "${product.name}-1",
                                              ),
                                            ),
                                          ),

                                          IconButton(
                                            icon: Icon(
                                              _favoriteProductIds.contains(
                                                    product.id,
                                                  )
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color:
                                                  _favoriteProductIds.contains(
                                                        product.id,
                                                      )
                                                      ? Colors.red
                                                      : Colors.grey,
                                            ),
                                            onPressed: () {
                                              _addOrRemoveFavorite(product.id);
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${product.price.toStringAsFixed(2)} \$",
                                                style: GoogleFonts.poppins(
                                                  color: ColorPalette.black,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                width: width * 0.26,
                                                child: Text(
                                                  product.name,
                                                  style: GoogleFonts.poppins(
                                                    color: ColorPalette.black,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 25,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color:
                                                  _cartProductIds.contains(
                                                        product.id,
                                                      )
                                                      ? ColorPalette.primary
                                                      : Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                    _cartProductIds.contains(
                                                          product.id,
                                                        )
                                                        ? ColorPalette.primary
                                                        : Colors.black,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                _cartProductIds.contains(
                                                      product.id,
                                                    )
                                                    ? Icons.shopping_cart
                                                    : Icons
                                                        .shopping_cart_outlined,
                                                color:
                                                    _cartProductIds.contains(
                                                          product.id,
                                                        )
                                                        ? Colors.white
                                                        : Colors.black,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                _addOrRemoveCart(product.id);
                                              },

                                              padding: const EdgeInsets.all(1),
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                SizedBox(height: height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmallPicture(
                      width: width,
                      height: height,
                      image: 'images/scuba.jpg',
                      text: 'Scuba Diving',
                    ),
                    SmallPicture(
                      width: width,
                      height: height,
                      image: 'images/offer.jpg',
                      text: 'Special Offers',
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                BigPicture(
                  width: width,
                  height: height,
                  image: "images/information.jpg",
                  text: "Take Informations About Scuba Diving",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Most Viewed Products",
                      style: GoogleFonts.poppins(
                        color: ColorPalette.black,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TopViewedProductsPage(),
                          ),
                        );
                      },
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          color: ColorPalette.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: height * 0.23,
                  child:
                      _isLoadingTopViewed
                          ? Center(
                            child: LoadingAnimationWidget.hexagonDots(
                              color: ColorPalette.primary,
                              size: height * 0.05,
                            ),
                          )
                          : _topViewedProducts.isEmpty && !_isLoadingTopViewed
                          ? const Center(child: Text('Products not find.'))
                          : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _topViewedProducts.length,
                            separatorBuilder:
                                (context, index) =>
                                    SizedBox(width: width * 0.02),
                            itemBuilder: (context, index) {
                              final product2 = _topViewedProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ProductPage(
                                            productId: product2.id,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: width * 0.35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: ColorPalette.black,
                                      width: 0.2,
                                    ),
                                    color: ColorPalette.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        alignment: Alignment.topLeft,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(7),
                                                  topRight: Radius.circular(7),
                                                ),
                                            child: Container(
                                              width: width * 0.35,
                                              height: height * 0.15,
                                              color: Colors.transparent,
                                              alignment: Alignment.center,
                                              child: Picture(
                                                baseUrl:
                                                    "https://scuba-diving-s3-bucket.s3.eu-north-1.amazonaws.com/products",
                                                fileName: "${product2.name}-1",
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              _favoriteProductIds.contains(
                                                    product2.id,
                                                  )
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color:
                                                  _favoriteProductIds.contains(
                                                        product2.id,
                                                      )
                                                      ? Colors.red
                                                      : Colors.grey,
                                            ),
                                            onPressed: () {
                                              _addOrRemoveFavorite(product2.id);
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${product2.price.toStringAsFixed(2)} \$",
                                                style: GoogleFonts.poppins(
                                                  color: ColorPalette.black,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                width: width * 0.26,
                                                child: Text(
                                                  product2.name,
                                                  style: GoogleFonts.poppins(
                                                    color: ColorPalette.black,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 25,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color:
                                                  _cartProductIds.contains(
                                                        product2.id,
                                                      )
                                                      ? ColorPalette.primary
                                                      : Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                    _cartProductIds.contains(
                                                          product2.id,
                                                        )
                                                        ? ColorPalette.primary
                                                        : Colors.black,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                _cartProductIds.contains(
                                                      product2.id,
                                                    )
                                                    ? Icons.shopping_cart
                                                    : Icons
                                                        .shopping_cart_outlined,
                                                color:
                                                    _cartProductIds.contains(
                                                          product2.id,
                                                        )
                                                        ? Colors.white
                                                        : Colors.black,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                _addOrRemoveCart(product2.id);
                                              },

                                              padding: const EdgeInsets.all(1),
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmallPicture extends StatelessWidget {
  const SmallPicture({
    super.key,
    required this.width,
    required this.height,
    required this.image,
    required this.text,
  });

  final double width;
  final double height;
  final String image;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (text == "Special Offers") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SpecialOffers()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WhichCategory(CategoryName: text),
            ),
          );
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: width * 0.45,
        height: height * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class BigPicture extends StatelessWidget {
  const BigPicture({
    super.key,
    required this.width,
    required this.height,
    required this.image,
    required this.text,
  });

  final double width;
  final double height;
  final String image;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TakeInfo()),
        );
      },
      child: Container(
        alignment: Alignment.center,
        width: width * 0.92,
        height: height * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
