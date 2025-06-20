// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num).toInt(),
      description: json['description'] as String?,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      features: json['features'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      mainPictureUrl: json['mainPictureUrl'] as String,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'price': instance.price,
      'discountPrice': instance.discountPrice,
      'stock': instance.stock,
      'description': instance.description,
      'reviewCount': instance.reviewCount,
      'features': instance.features,
      'isActive': instance.isActive,
      'favoriteCount': instance.favoriteCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'mainPictureUrl': instance.mainPictureUrl,
    };
