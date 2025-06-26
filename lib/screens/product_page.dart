import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/product.dart';
import 'package:scuba_diving/models/review.dart';
import 'package:scuba_diving/screens/picture/picture.dart';
import 'package:scuba_diving/screens/product_comments_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  final int productId;

  const ProductPage({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product? _product;
  bool _isLoading = true;
  String _errorMessage = '';

  String? _currentUserId;
  Set<int> _favoriteProductIds = {};
  Set<int> _cartProductIds = {};
  bool _isFavorite = false;
  bool _isInCart = false;
  double _averageRating = 0.0;
  int _reviewCount = 0;

  List<Review> _reviews = [];

  Future<void> _fetchProductReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http
          .get(
            Uri.parse('$API_BASE_URL/api/Review/product/${widget.productId}'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> reviewJsonList = json.decode(response.body);
        if (mounted) {
          setState(() {
            _reviews =
                reviewJsonList.map((json) => Review.fromJson(json)).toList();
            _calculateReviewStats();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load reviews: ${response.statusCode}';
            _isLoading = false;
          });
        }
        print(
          'Reviews fetch failed: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Reviews request timed out: $e';
          _isLoading = false;
        });
      }
      print('Timeout fetching reviews: $e');
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error fetching reviews: $e';
          _isLoading = false;
        });
      }
      print('Network error fetching reviews: $e');
    }
  }

  void _calculateReviewStats() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      _reviewCount = 0;
      return;
    }

    double totalRating = 0;
    for (var review in _reviews) {
      totalRating += review.rating.toDouble();
    }
    _averageRating = totalRating / _reviews.length;
    _reviewCount = _reviews.length;
  }

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _loadUserDataAndFavorites();
    _loadUserDataAndCartItems();
    _fetchProductReviews();
  }

  Future<void> _loadUserDataAndFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserFavorites(_currentUserId!);
      setState(() {
        _isFavorite = _favoriteProductIds.contains(widget.productId);
      });
    }
  }

  Future<void> _loadUserDataAndCartItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserCartItems(_currentUserId!);
      setState(() {
        _isInCart = _cartProductIds.contains(widget.productId);
      });
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
          _isFavorite = _favoriteProductIds.contains(widget.productId);
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
          _isInCart = _cartProductIds.contains(widget.productId);
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

  Future<void> _fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/Product/${widget.productId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> productJson = json.decode(response.body);
        setState(() {
          _product = Product.fromJson(productJson);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load product: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching product details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to add to favorites.'),
        ),
      );
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token not found. Favorite operation could not be performed.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Authentication error.')));
      return;
    }

    final String apiUrl = '$API_BASE_URL/api/Favorites';
    final Map<String, dynamic> body = {
      'productId': widget.productId,
      'userId': _currentUserId,
    };

    try {
      http.Response response;
      if (_isFavorite) {
        response = await http.delete(
          Uri.parse(
            '$API_BASE_URL/api/Favorites/$_currentUserId/${widget.productId}',
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $authToken',
          },
        );
      } else {
        response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode(body),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _isFavorite = !_isFavorite;
          if (_isFavorite) {
            _favoriteProductIds.add(widget.productId);
          } else {
            _favoriteProductIds.remove(widget.productId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? 'Product added to favorites!'
                  : 'Product removed from favorites.',
            ),
          ),
        );
        _fetchProductDetails();
      } else {
        print(
          'Favorite operation failed: ${response.statusCode} - ${response.body}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorite operation failed.')),
        );
      }
    } catch (e) {
      print('Network error during favorite operation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred during favorite operation.'),
        ),
      );
    }
  }

  Future<void> _addToCart() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add to cart.')),
      );
      return;
    }

    if (_isInCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is already in your cart.')),
      );
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token not found. Could not add to cart.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Authentication error.')));
      return;
    }

    final String apiUrl = '$API_BASE_URL/api/CartItem';
    final Map<String, dynamic> body = {
      'productId': widget.productId,
      'userId': _currentUserId,
      'quantity': 1,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          _isInCart = true;
          _cartProductIds.add(widget.productId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product added to cart!')));
      } else {
        print('Add to cart failed: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add to cart.')));
      }
    } catch (e) {
      print('Network error during add to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during add to cart.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body:
            _isLoading
                ? Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    color: ColorPalette.primary,
                    size: height * 0.05,
                  ),
                )
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : _product == null
                ? const Center(child: Text('Product not found.'))
                : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorPalette.cardColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _toggleFavorite,
                              icon: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: height * 0.4,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Picture(
                          baseUrl:
                              "https://scuba-diving-s3-bucket.s3.eu-north-1.amazonaws.com/products",
                          fileName: "${_product?.name}-1",
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _product!.name,
                        style: GoogleFonts.poppins(
                          color: ColorPalette.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: ColorPalette.cardColor,
                            ),
                            width: width * 0.4,
                            height: height * 0.05,
                            alignment: Alignment.center,
                            child: RatingBar.builder(
                              itemSize: 16,
                              initialRating: _averageRating,
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              itemBuilder:
                                  (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                              onRatingUpdate: (rating) {},
                              ignoreGestures: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductCommentsPage(
                                        productId: _product?.id ?? 0,
                                        productName: _product?.name ?? "",
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: ColorPalette.cardColor,
                              ),
                              width: width * 0.45,
                              height: height * 0.05,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Show the comments",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: ColorPalette.primary,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.comment,
                                      color: ColorPalette.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: ColorPalette.cardColor,
                            ),
                            width: width * 0.18,
                            height: height * 0.05,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${_product!.favoriteCount ?? 0}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.favorite, color: Colors.red),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: ColorPalette.cardColor,
                            ),
                            width: width * 0.18,
                            height: height * 0.05,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${_product!.reviewCount ?? 0}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.reviews, color: Colors.grey[700]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        '\$${_product!.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          color: ColorPalette.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        'Brand: ${_product!.brand}',
                        style: GoogleFonts.poppins(
                          color: ColorPalette.black,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        _product!.description ?? "",
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: ColorPalette.black70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      if (_product!.features != null &&
                          _product!.features!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Features',
                              style: GoogleFonts.poppins(
                                color: ColorPalette.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._product!.features!.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 18,
                                      color: ColorPalette.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${entry.key}: ${entry.value}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: ColorPalette.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      SizedBox(height: height * 0.03),
                      GestureDetector(
                        onTap: _isInCart ? null : _addToCart,
                        child: Container(
                          height: height * 0.08,
                          width: width,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color:
                                _isInCart ? Colors.grey : ColorPalette.primary,
                          ),
                          child: Text(
                            _isInCart ? "In Cart" : "Add to cart",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
