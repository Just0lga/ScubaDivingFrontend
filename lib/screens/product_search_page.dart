import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/product.dart';
import 'package:scuba_diving/models/cart.dart'; // Sepet modeli import edildi
import 'package:scuba_diving/models/favorite.dart'; // Favori modeli import edildi
import 'package:scuba_diving/screens/product_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ürün detay sayfası için

class ProductSearchPage extends StatefulWidget {
  final String initialQuery; // İlk arama sorgusu
  const ProductSearchPage({super.key, this.initialQuery = ''});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  bool _isLoading = false;
  String _currentQuery = '';

  // Favori ve Sepet işlemleri için gerekli state değişkenleri
  String? _currentUserId; // Mevcut kullanıcının ID'si
  Set<int> _favoriteProductIds = {}; // Kullanıcının favori ürün ID'leri seti
  Set<int> _cartProductIds =
      {}; // Kullanıcının sepetindeki ürün ID'lerini tutar

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _currentQuery = widget.initialQuery;

    // Kullanıcı verilerini ve favorileri/sepeti yükle
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

  // MARK: - Sepet İşlemleri
  // Kullanıcı verilerini ve sepet öğelerini yükler
  Future<void> _loadUserDataAndCartItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserCartItems(_currentUserId!);
    }
  }

  // Kullanıcının sepetindeki ürünleri backend'den çeker
  Future<void> _fetchUserCartItems(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token bulunamadı. Sepet öğeleri çekilemedi.');
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
        print('Sepet ürün ID\'leri başarıyla çekildi: $_cartProductIds');
      } else {
        print(
          'Sepet ürünleri çekilirken hata oluştu: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Sepet ürünleri çekilirken ağ hatası oluştu: $e');
    }
  }

  // Ürünü sepete ekler veya sepetten kaldırır
  Future<void> _addOrRemoveCart(int productId) async {
    if (_currentUserId == null) {
      _showSnackBar('Sepete eklemek için lütfen giriş yapın.', Colors.orange);
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

    final bool isCurrentlyCart = _cartProductIds.contains(productId);

    // Optimistik güncelleme: UI'yı önce güncelle
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
        // Ürün şu anda sepette ise -> SEPETTEN KALDIR (DELETE isteği)
        final String deleteUrl =
            '$API_BASE_URL/api/CartItem/$_currentUserId/$productId';
        print('DELETE isteği gönderiliyor: $deleteUrl');
        response = await http.delete(
          Uri.parse(deleteUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $authToken',
          },
        );
      } else {
        // Ürün şu anda sepette değil ise -> SEPTE EKLE (POST isteği)
        final String postUrl = '$API_BASE_URL/api/CartItem';
        final cart = Cart(
          userId: _currentUserId!,
          productId: productId,
          quantity: 1,
        );
        final String requestBody = jsonEncode(cart.toJson());
        print('POST isteği gönderiliyor: $postUrl ile gövde: $requestBody');
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
          isCurrentlyCart ? 'Sepetten kaldırıldı!' : 'Sepete eklendi!',
          Colors.green,
        );
        print(
          'Sepet işlemi başarılı: ${response.statusCode} - ${response.body}',
        );
      } else {
        // Hata oluştu, UI'yı eski durumuna geri al
        setState(() {
          if (isCurrentlyCart) {
            _cartProductIds.add(productId);
          } else {
            _cartProductIds.remove(productId);
          }
        });
        String errorMessage = 'Sepet işlemi başarısız: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          print('Hata gövdesi ayrıştırılırken hata oluştu: $e');
        }
        _showSnackBar(errorMessage, Colors.red);
        print('Sepet API Hatası: ${response.statusCode} - ${response.body}');
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
      print('Sepet isteği gönderilirken hata: $e');
    }
  }

  // MARK: - Favori İşlemleri
  // Kullanıcı ID'sini yükler ve favorileri çeker
  Future<void> _loadUserDataAndFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserFavorites(_currentUserId!);
    }
    // Arama fonksiyonu burada çağrılmıyor çünkü _searchProducts
    // widget.initialQuery'ye göre zaten initState'de çağrılıyor.
    // Eğer favoriler yüklendikten sonra arama sonuçlarının güncellenmesi gerekiyorsa
    // _searchProducts(_currentQuery); buraya eklenebilir.
  }

  // Kullanıcının favori ürünlerini backend'den çeker
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

  // Bir ürünü favorilere ekler veya favorilerden kaldırır
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
        print('DELETE isteği gönderiliyor: $deleteUrl');
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
        print('POST isteği gönderiliyor: $postUrl ile gövde: $requestBody');
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
          'Favori işlemi başarılı: ${response.statusCode} - ${response.body}',
        );
      } else {
        // Hata oluştu, UI'yı eski durumuna geri al (rollback)
        setState(() {
          if (isCurrentlyFavorited) {
            _favoriteProductIds.add(productId); // Kaldırılamadıysa geri ekle
          } else {
            _favoriteProductIds.remove(productId); // Eklenemediyse geri kaldır
          }
        });
        String errorMessage = 'Favori işlemi başarısız: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          print('Hata gövdesi ayrıştırılırken hata: $e');
        }
        _showSnackBar(errorMessage, Colors.red);
        print('Favori API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Ağ hatası oluştu, UI'yı eski durumuna geri al (rollback)
      setState(() {
        if (isCurrentlyFavorited) {
          _favoriteProductIds.add(productId);
        } else {
          _favoriteProductIds.remove(productId);
        }
      });
      _showSnackBar('Bir ağ hatası oluştu: $e', Colors.red);
      print('Favori isteği gönderilirken hata: $e');
    }
  }

  // MARK: - Ürün Arama
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
      _searchResults = []; // Yeni arama için önceki sonuçları temizle
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
        _showSnackBar('Ürünler çekilemedi: ${response.statusCode}', Colors.red);
        print(
          'Arama sonuçları yüklenirken hata oluştu: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _showSnackBar('Bir hata oluştu: $e', Colors.red);
      print('Arama sonuçları çekilirken hata: $e');
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
            hintStyle: GoogleFonts.playfair(color: ColorPalette.black70),
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
                          size: height * 0.03, // Yükleme ikonu boyutu ayarlandı
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
          style: GoogleFonts.playfair(color: ColorPalette.black, fontSize: 18),
          onSubmitted: (value) {
            _searchProducts(value); // Enter'a basıldığında ara
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
                child: Text('Aradığınız kritere uygun ürün bulunamadı.'),
              )
              : _searchResults.isEmpty && _currentQuery.isEmpty && !_isLoading
              ? const Center(
                child: Text('Aramaya başlamak için bir anahtar kelime girin.'),
              )
              : GridView.builder(
                padding: EdgeInsets.all(width * 0.04),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: width * 0.04,
                  mainAxisSpacing: height * 0.02,
                  childAspectRatio:
                      0.7, // Kart boyutunu artırmak için ayarlandı
                ),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      // Ürüne tıklandığında ürün detay sayfasına git
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
                        color: ColorPalette.cardColor, // Kart arka plan rengi
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
                                  width:
                                      double
                                          .infinity, // Resim alanı kart genişliği kadar
                                  height: height * 0.15,
                                  color: Colors.yellow[200], // Placeholder renk
                                  alignment: Alignment.center,
                                  // TODO: Burada gerçek resmi yüklemek için Image.network kullanılmalıdır.
                                  // product.mainPictureUrl eğer geçerli bir URL ise:
                                  // child: Image.network(product.mainPictureUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Text('Resim Yok')),
                                  child: Text(
                                    product.mainPictureUrl.isEmpty
                                        ? 'No Image'
                                        : 'Image for: ${product.name}', // Geçici olarak resim URL'si veya placeholder metin
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                              // Favori kalp ikonu
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
                                // Sepete ekle butonu
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
