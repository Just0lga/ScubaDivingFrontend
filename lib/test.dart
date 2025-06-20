import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:scuba_diving/models/product.dart'; // Product modelinizi import edin

// SADECE GELİŞTİRME AMAÇLIDIR, ÜRETİMDE KULLANILMAMALIDIR!
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ürün Listesi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ProductListScreen(),
    );
  }
}

// --- Product List Screen ---
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = false;
  int _currentPage = 1; // Şu anki sayfa
  final int _pageSize = 3; // Her sayfada kaç ürün gösterileceği
  bool _canGoNext = true; // Daha fazla sayfa olup olmadığını kontrol eder

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // İlk yüklemede ürünleri çek
  }

  Future<void> _fetchProducts({int? pageNumber}) async {
    // Eğer zaten yükleme yapılıyorsa veya istek bir sebepten ötürü geçersizse geri dön
    if (_isLoading) return;

    setState(() {
      _isLoading = true; // Yükleme başladı
      if (pageNumber != null) {
        _currentPage = pageNumber; // Belirli bir sayfaya gitmek için
      }
    });

    final String apiUrl =
        'https://10.0.2.2:7096/api/Product/all-products-paged?PageNumber=$_currentPage&PageSize=$_pageSize';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response.body);
        List<Product> newProducts =
            productsJson.map((json) => Product.fromJson(json)).toList();

        setState(() {
          _products = newProducts;
          // Gelen ürün sayısı istenen sayfa boyutundan küçükse, bu son sayfa demektir.
          _canGoNext = newProducts.length == _pageSize;
        });
      } else {
        _showSnackBar('Ürünler çekilemedi: ${response.statusCode}', Colors.red);
        print(
          'Failed to load products: ${response.statusCode} - ${response.body}',
        );
        setState(() {
          _canGoNext = false; // Hata durumunda ileri gitmeyi durdur
        });
      }
    } catch (e) {
      _showSnackBar('Bir hata oluştu: $e', Colors.red);
      print('Error fetching products: $e');
      setState(() {
        _canGoNext = false; // Hata durumunda ileri gitmeyi durdur
      });
    } finally {
      setState(() {
        _isLoading = false; // Yükleme bitti
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // Önceki sayfaya gitmek
  void _goToPreviousPage() {
    if (_currentPage > 1 && !_isLoading) {
      // İlk sayfada değilsek ve yükleme yoksa
      _fetchProducts(pageNumber: _currentPage - 1);
    }
  }

  // Sonraki sayfaya gitmek
  void _goToNextPage() {
    if (_canGoNext && !_isLoading) {
      // Daha fazla ürün varsa ve yükleme yoksa
      _fetchProducts(pageNumber: _currentPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürünler')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              // Yükleme göstergesini listenin üzerine bindirmek için Stack kullanıyoruz
              children: [
                _products.isEmpty &&
                        !_isLoading // Ürün yoksa ve yükleme bitmişse 'Ürün bulunamadı' göster
                    ? const Center(child: Text('Ürün bulunamadı.'))
                    : RefreshIndicator(
                      onRefresh:
                          () => _fetchProducts(
                            pageNumber: 1,
                          ), // Yenilemede ilk sayfayı çek
                      child: ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Marka: ${product.brand}'),
                                  Text(
                                    'Fiyat: ${product.price.toStringAsFixed(2)} TL (İndirimli: ${product.discountPrice.toStringAsFixed(2)} TL)',
                                  ),
                                  Text('Stok: ${product.stock}'),
                                  if (product.description != null &&
                                      product.description!.isNotEmpty)
                                    Text('Açıklama: ${product.description}'),
                                  Text('Yorum Sayısı: ${product.reviewCount}'),
                                  if (product.features != null &&
                                      product.features!.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Özellikler:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ...product.features!.entries.map(
                                          (entry) => Text(
                                            '${entry.key}: ${entry.value}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  Text(
                                    'Oluşturulma Tarihi: ${product.createdAt.toLocal().toString().split(' ')[0]}',
                                  ),
                                  Text(
                                    'Güncelleme Tarihi: ${product.updatedAt.toLocal().toString().split(' ')[0]}',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                // Yükleme göstergesi (indicator)
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          // Sayfa navigasyon butonları (Geri/İleri)
          Padding(
            // Butonlar her zaman görünür olsun, ancak yüklenirken tıklanamasın
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Geri'),
                  onPressed:
                      _currentPage > 1 && !_isLoading
                          ? _goToPreviousPage
                          : null, // İlk sayfada veya yüklenirken devre dışı
                ),
                Text('Sayfa $_currentPage'),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('İleri'),
                  onPressed:
                      _canGoNext && !_isLoading
                          ? _goToNextPage
                          : null, // Daha fazla ürün yoksa veya yüklenirken devre dışı
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
