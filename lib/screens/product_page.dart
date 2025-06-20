import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences için eklendi

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

  // Favori ve Sepet için yeni state değişkenleri
  String? _currentUserId;
  Set<int> _favoriteProductIds = {};
  Set<int> _cartProductIds = {};
  bool _isFavorite = false; // Mevcut ürün favori mi?
  bool _isInCart = false; // Mevcut ürün sepette mi?

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _loadUserDataAndFavorites(); // Favorileri çek
    _loadUserDataAndCartItems(); // Sepet öğelerini çek
  }

  // Kullanıcı ID'sini yükle ve favorileri çek
  Future<void> _loadUserDataAndFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserFavorites(_currentUserId!);
      // Favori listesi çekildikten sonra mevcut ürünün favori olup olmadığını kontrol et
      setState(() {
        _isFavorite = _favoriteProductIds.contains(widget.productId);
      });
    }
  }

  // Kullanıcı ID'sini yükle ve sepet öğelerini çek
  Future<void> _loadUserDataAndCartItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });

    if (_currentUserId != null) {
      await _fetchUserCartItems(_currentUserId!);
      // Sepet listesi çekildikten sonra mevcut ürünün sepette olup olmadığını kontrol et
      setState(() {
        _isInCart = _cartProductIds.contains(widget.productId);
      });
    }
  }

  // Kullanıcının favori ürünlerini backend'den çek
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
          _isFavorite = _favoriteProductIds.contains(
            widget.productId,
          ); // Sayfa yüklendiğinde favori durumunu güncelle
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

  // Kullanıcının sepet öğelerini backend'den çek
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
          _isInCart = _cartProductIds.contains(
            widget.productId,
          ); // Sayfa yüklendiğinde sepet durumunu güncelle
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

  // Favoriye ekleme/çıkarma fonksiyonu
  Future<void> _toggleFavorite() async {
    if (_currentUserId == null) {
      // Kullanıcı giriş yapmamışsa uyarı göster veya giriş sayfasına yönlendir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Favorilere eklemek için giriş yapmalısınız.')),
      );
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token bulunamadı. Favori işlemi yapılamadı.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yetkilendirme hatası.')));
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
        // Favorilerden çıkar
        response = await http.delete(
          Uri.parse(
            '$API_BASE_URL/api/Favorites/$_currentUserId/${widget.productId}',
          ), // CORRECTED URL
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $authToken',
          },
        );
      } else {
        // Favorilere ekle
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
        // 204 No Content is common for successful DELETE
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
                  ? 'Ürün favorilere eklendi!'
                  : 'Ürün favorilerden çıkarıldı.',
            ),
          ),
        );
        // Favori sayısı da güncellenmeli (ürün modelinde favoriteCount alanı varsa)
        // Eğer ürün modelinizde favoriteCount doğrudan güncellenmiyorsa, yeniden fetch etmeniz gerekebilir.
        _fetchProductDetails(); // FavoriteCount'u güncellemek için ürünü tekrar çek
      } else {
        print(
          'Favori işlemi başarısız: ${response.statusCode} - ${response.body}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favori işlemi başarısız oldu.')),
        );
      }
    } catch (e) {
      print('Favori işlemi sırasında ağ hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Favori işlemi sırasında bir hata oluştu.')),
      );
    }
  }

  // Sepete ekleme fonksiyonu
  Future<void> _addToCart() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sepete eklemek için giriş yapmalısınız.')),
      );
      return;
    }

    if (_isInCart) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bu ürün zaten sepetinizde.')));
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token bulunamadı. Sepete ekleme yapılamadı.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yetkilendirme hatası.')));
      return;
    }

    final String apiUrl = '$API_BASE_URL/api/CartItem';
    final Map<String, dynamic> body = {
      'productId': widget.productId,
      'userId': _currentUserId,
      'quantity': 1, // Varsayılan olarak 1 adet ekle
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
        // 201 Created veya 200 OK
        setState(() {
          _isInCart = true;
          _cartProductIds.add(widget.productId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ürün sepete eklendi!')));
      } else {
        print(
          'Sepete ekleme başarısız: ${response.statusCode} - ${response.body}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sepete ekleme başarısız oldu.')),
        );
      }
    } catch (e) {
      print('Sepete ekleme sırasında ağ hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sepete ekleme sırasında bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
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
                              Navigator.pop(
                                context,
                                true,
                              ); // Pass true to indicate an update might be needed
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
                            ),
                          ),
                          // Favori Butonu
                          Container(
                            decoration: BoxDecoration(
                              color: ColorPalette.cardColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _toggleFavorite, // Favori fonksiyonu
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
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "images/freediving.jpg", // Use the image from the product model
                          width: double.infinity,
                          height: height * 0.3,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _product!.name,
                        style: GoogleFonts.playfair(
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
                              initialRating:
                                  _product!.id
                                      .toDouble() ?? // This likely should be product.rating, not product.id
                                  0.0, // Backend'den gelen rating'i kullan
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              itemBuilder:
                                  (context, _) =>
                                      Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: ColorPalette.cardColor,
                            ),
                            width: width * 0.45,
                            height: height * 0.05,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Show the comments",
                                    style: GoogleFonts.playfair(
                                      fontSize: 12,
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
                                  "${_product!.favoriteCount ?? 0}", // Null kontrolü ekleyin
                                  style: GoogleFonts.playfair(
                                    fontSize: 20,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.favorite, color: Colors.red),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
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
                                  "${_product!.reviewCount ?? 0}", // Null kontrolü ekleyin
                                  style: GoogleFonts.playfair(
                                    fontSize: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.reviews, color: Colors.grey[700]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        '\$${_product!.price.toStringAsFixed(2)}',
                        style: GoogleFonts.playfair(
                          color: ColorPalette.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        'Brand: ${_product!.brand}',
                        style: GoogleFonts.playfair(
                          color: ColorPalette.black,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        _product!.description ?? "",
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfair(
                          color: ColorPalette.black70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      // --- ÜRÜN ÖZELLİKLERİ BAŞLANGICI ---
                      if (_product!.features != null &&
                          _product!.features!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Features',
                              style: GoogleFonts.playfair(
                                color: ColorPalette.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            ..._product!.features!.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 18,
                                      color: ColorPalette.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${entry.key}: ${entry.value}',
                                        style: GoogleFonts.playfair(
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
                      // --- ÜRÜN ÖZELLİKLERİ SONU ---
                      SizedBox(height: height * 0.03),
                      GestureDetector(
                        // Sepete Ekle butonu için GestureDetector eklendi
                        onTap: _addToCart, // Sepete ekleme fonksiyonu
                        child: Container(
                          height: height * 0.08,
                          width: width,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color:
                                _isInCart
                                    ? Colors.grey
                                    : ColorPalette
                                        .primary, // Sepetteyse rengi değiştir
                          ),
                          child: Text(
                            _isInCart
                                ? "In Cart"
                                : "Add to cart", // Sepetteyse metni değiştir
                            style: GoogleFonts.playfair(
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
