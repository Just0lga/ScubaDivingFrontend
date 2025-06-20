import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/cart.dart';
import 'package:scuba_diving/models/favorite.dart';
import 'package:scuba_diving/models/product.dart';
import 'package:scuba_diving/screens/product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MostFavoritedProductsPage extends StatefulWidget {
  const MostFavoritedProductsPage({super.key});

  @override
  State<MostFavoritedProductsPage> createState() =>
      _MostFavoritedProductsPageState();
}

class _MostFavoritedProductsPageState extends State<MostFavoritedProductsPage> {
  List<Product> _products = [];
  bool _isLoading = false;
  int _pageNumber = 1;
  final int _pageSize = 12; // Her sayfada 12 ürün gösterilecek
  bool _hasMore = true; // Daha yüklenecek ürün olup olmadığını kontrol eder
  final ScrollController _scrollController = ScrollController();

  // Yeni eklenecekler
  String? _currentUserId; // Kullanıcının ID'sini tutar
  Set<int> _favoriteProductIds = {}; // Kullanıcının favori ürün ID'lerini tutar
  Set<int> _cartProductIds = {}; // Kullanıcının favori ürün ID'lerini tutar

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFavorites(); // Kullanıcı verilerini ve favorileri yükle
    _loadUserDataAndCartItems();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _hasMore &&
          !_isLoading) {
        _fetchProducts(); // Listenin sonuna gelindiğinde ve daha fazla varsa yeni ürünleri çek
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //CART ITEMS
  Future<void> _loadUserDataAndCartItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserCartItems(_currentUserId!);
    }
  }

  // Kullanıcının favori ürünlerini backend'den çek
  Future<void> _fetchUserCartItems(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token bulunamadı. Favoriler çekilemedi.');
      return;
    }

    // Kullanıcının ID'sine göre favorileri çeken URL'niz
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
          // Gelen JSON listesindeki her bir nesneden 'productId' değerini çek
          _cartProductIds =
              cartData
                  .map<int>(
                    (item) => item['productId'] as int,
                  ) // Her bir Map'ten productId'yi al
                  .toSet(); // Benzersiz favori ID'leri için Set'e dönüştür
        });
        print('Cart ürün ID\'leri başarıyla çekildi: $_cartProductIds');
      } else {
        print(
          'Cart ürünleri çekilirken hata oluştu: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Cart ürünleri çekilirken ağ hatası oluştu: $e');
    }
  }

  Future<void> _addOrRemoveCart(int productId) async {
    if (_currentUserId == null) {
      _showSnackBar('Carta eklemek için lütfen giriş yapın.', Colors.orange);
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      _showSnackBar(
        'Oturum token\'ı bulunamadı. Lütfen tekrar giriş yapın.',
        Colors.orange,
      );
      return;
    }

    final bool isCurrentlyCart = _cartProductIds.contains(
      productId,
    ); // Mevcut durumu kontrol et

    // Optimistik güncelleme: UI'yı önce güncelle
    setState(() {
      if (isCurrentlyCart) {
        _cartProductIds.remove(
          productId,
        ); // Favoriden kaldırılacaksa setten çıkar
      } else {
        _cartProductIds.add(productId); // Favoriye eklenecekse sete ekle
      }
    });

    try {
      http.Response response;

      if (isCurrentlyCart) {
        // Ürün şu anda favorilerde ise -> FAVORİDEN KALDIR (DELETE isteği)
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
        // Ürün şu anda favorilerde değil ise -> FAVORİYE EKLE (POST isteği)
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
        // 200 OK (Genel başarı), 201 Created (Ekleme Başarısı), 204 No Content (DELETE Başarısı)
        _showSnackBar(
          isCurrentlyCart ? 'Cart kaldırıldı!' : 'Cart eklendi!',
          Colors.green,
        );
        print(
          'Cart operation success: ${response.statusCode} - ${response.body}',
        );
        // UI zaten optimistik olarak güncellendi. Ekstra bir setState burada gerekli değil.
      } else {
        // Hata oluştu, UI'yı eski durumuna geri al
        setState(() {
          if (isCurrentlyCart) {
            _cartProductIds.add(
              productId,
            ); // Kaldırmıştık, hata oldu, geri ekle
          } else {
            _cartProductIds.remove(
              productId,
            ); // Eklememiştik, hata oldu, geri kaldır
          }
        });
        String errorMessage = 'Favori işlemi başarısız: ${response.statusCode}';
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
      // Ağ hatası oluştu, UI'yı eski durumuna geri al
      setState(() {
        if (isCurrentlyCart) {
          _cartProductIds.add(productId);
        } else {
          _cartProductIds.remove(productId);
        }
      });
      _showSnackBar('Bir ağ hatası oluştu: $e', Colors.red);
      print('Error sending favorite request: $e');
    }
  }

  // Kullanıcı ID'sini yükle ve favorileri çek
  Future<void> _loadUserDataAndFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserFavorites(_currentUserId!);
    }
    // Favori ürünler yüklendikten sonra ürünleri çek
    _fetchProducts();
  }

  // Kullanıcının favori ürünlerini backend'den çekme metodu
  Future<void> _fetchUserFavorites(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token bulunamadı. Favoriler çekilemedi.');
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
        print('Favori ürün ID\'leri başarıyla çekildi: $_favoriteProductIds');
      } else {
        print(
          'Favori ürünleri çekilirken hata oluştu: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Favori ürünleri çekilirken ağ hatası oluştu: $e');
    }
  }

  // Favori ekleme/kaldırma işlemi
  Future<void> _addOrRemoveFavorite(int productId) async {
    if (_currentUserId == null) {
      _showSnackBar('Favori eklemek için lütfen giriş yapın.', Colors.orange);
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      _showSnackBar(
        'Oturum token\'ı bulunamadı. Lütfen tekrar giriş yapın.',
        Colors.orange,
      );
      return;
    }

    final bool isCurrentlyFavorited = _favoriteProductIds.contains(productId);

    // Optimistik güncelleme: UI'yı önce güncelle
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
        // Ürün şu anda favorilerde ise -> FAVORİDEN KALDIR (DELETE isteği)
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
        // Ürün şu anda favorilerde değil ise -> FAVORİYE EKLE (POST isteği)
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
          isCurrentlyFavorited ? 'Favori kaldırıldı!' : 'Favori eklendi!',
          Colors.green,
        );
        print(
          'Favorite operation success: ${response.statusCode} - ${response.body}',
        );
      } else {
        // Hata oluştu, UI'yı eski durumuna geri al
        setState(() {
          if (isCurrentlyFavorited) {
            _favoriteProductIds.add(productId);
          } else {
            _favoriteProductIds.remove(productId);
          }
        });
        String errorMessage = 'Favori işlemi başarısız: ${response.statusCode}';
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
      // Ağ hatası oluştu, UI'yı eski durumuna geri al
      setState(() {
        if (isCurrentlyFavorited) {
          _favoriteProductIds.add(productId);
        } else {
          _favoriteProductIds.remove(productId);
        }
      });
      _showSnackBar('Bir ağ hatası oluştu: $e', Colors.red);
      print('Error sending favorite request: $e');
    }
  }

  Future<void> _fetchProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final String apiUrl =
        '$API_BASE_URL/api/Product/most-favorited-paged?PageNumber=$_pageNumber&PageSize=$_pageSize';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response.body);
        List<Product> fetchedProducts =
            productsJson.map((json) => Product.fromJson(json)).toList();

        setState(() {
          _products.addAll(fetchedProducts);
          _pageNumber++;
          if (fetchedProducts.length < _pageSize) {
            _hasMore = false;
          }
        });
      } else {
        _showSnackBar('Ürünler çekilemedi: ${response.statusCode}', Colors.red);
        print(
          'Failed to load products: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _showSnackBar('Bir hata oluştu: $e', Colors.red);
      print('Error fetching products: $e');
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
        centerTitle: true,
        title: Text(
          "Favorite Products",
          style: GoogleFonts.playfair(
            color: ColorPalette.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorPalette.white),
      ),
      body:
          _isLoading && _products.isEmpty
              ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                  color: ColorPalette.primary,
                  size: height * 0.05,
                ),
              )
              : _products.isEmpty && !_isLoading
              ? const Center(child: Text('Favori ürün bulunamadı.'))
              : GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(width * 0.04),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: width * 0.04,
                  mainAxisSpacing: height * 0.02,
                  childAspectRatio: 0.7,
                ),
                itemCount: _products.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _products.length) {
                    return _isLoading
                        ? Center(
                          child: LoadingAnimationWidget.hexagonDots(
                            color: ColorPalette.primary,
                            size: height * 0.05,
                          ),
                        )
                        : const SizedBox.shrink();
                  }
                  final product = _products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProductPage(productId: _products[index].id),
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
                        color: ColorPalette.cardColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Container(
                                height: height * 0.15,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(product.mainPictureUrl),
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
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${product.price.toStringAsFixed(2)} \$",
                                  style: GoogleFonts.playfair(
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
                                  style: GoogleFonts.playfair(
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
                                    height:
                                        25, // Added height for the container
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
                                      padding:
                                          EdgeInsets
                                              .zero, // Remove all internal padding
                                      constraints: BoxConstraints.tightFor(
                                        width: 25,
                                        height: 25,
                                      ), // Constrain the button to the container's size
                                      visualDensity:
                                          VisualDensity
                                              .compact, // Make the button more compact
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
