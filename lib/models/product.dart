import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    required String brand,
    required double price,
    @Default(0.0)
    double
    discountPrice, // Varsayılan değer ekleyerek null gelme ihtimaline karşı koruma
    required int stock,
    String? description, // Nullable
    @Default(0)
    int
    reviewCount, // Varsayılan değer ekleyerek null gelme ihtimaline karşı koruma
    Map<String, dynamic>? features, // Nullable Map
    @Default(true) bool isActive, // Varsayılan değer
    @Default(0) int favoriteCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String mainPictureUrl,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
