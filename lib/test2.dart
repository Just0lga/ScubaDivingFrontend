import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:scuba_diving/models/product.dart'; // Product modelinizi import edin

class HomePageWithFeaturedProducts extends StatefulWidget {
  const HomePageWithFeaturedProducts({super.key});

  @override
  State<HomePageWithFeaturedProducts> createState() =>
      _HomePageWithFeaturedProductsState();
}

class _HomePageWithFeaturedProductsState
    extends State<HomePageWithFeaturedProducts> {
  List<Product> _featuredProducts = [];
  bool _isLoading = false;
  final int _numberOfProductsToFetch = 3; // Sadece 3 ürün çekeceğiz

  @override
  void initState() {
    super.initState();
    _fetchFeaturedProducts(); // Sayfa yüklendiğinde ürünleri çek
  }

  Future<void> _fetchFeaturedProducts() async {
    if (_isLoading) return; // Zaten yükleniyorsa tekrar istek gönderme

    setState(() {
      _isLoading = true; // Yüklemeyi başlat
    });

    // API URL'si: Sadece ilk sayfadan _numberOfProductsToFetch kadar ürün istiyoruz.
    // PageNumber=1 ve PageSize=3 olacak şekilde ayarlandı.
    final String apiUrl =
        'https://10.0.2.2:7096/api/Product/all-products-paged?PageNumber=1&PageSize=$_numberOfProductsToFetch';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response.body);
        List<Product> fetchedProducts =
            productsJson.map((json) => Product.fromJson(json)).toList();

        setState(() {
          _featuredProducts = fetchedProducts;
        });
      } else {
        _showSnackBar(
          'Öne çıkan ürünler çekilemedi: ${response.statusCode}',
          Colors.red,
        );
        print(
          'Failed to load featured products: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _showSnackBar('Bir hata oluştu: $e', Colors.red);
      print('Error fetching featured products: $e');
    } finally {
      setState(() {
        _isLoading = false; // Yüklemeyi bitir
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body:
          _isLoading // Yüklenirken gösterge
              ? const Center(child: CircularProgressIndicator())
              : _featuredProducts
                  .isEmpty // Ürün yoksa
              ? const Center(
                child: Text('Gösterilecek öne çıkan ürün bulunamadı.'),
              )
              : ListView.builder(
                itemCount: _featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = _featuredProducts[index];
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
                          // Diğer ürün detaylarını da buraya ekleyebilirsiniz
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
