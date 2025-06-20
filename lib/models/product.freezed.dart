// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double get discountPrice =>
      throw _privateConstructorUsedError; // Varsayılan değer ekleyerek null gelme ihtimaline karşı koruma
  int get stock => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError; // Nullable
  int get reviewCount =>
      throw _privateConstructorUsedError; // Varsayılan değer ekleyerek null gelme ihtimaline karşı koruma
  Map<String, dynamic>? get features =>
      throw _privateConstructorUsedError; // Nullable Map
  bool get isActive => throw _privateConstructorUsedError; // Varsayılan değer
  int get favoriteCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get mainPictureUrl => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    int id,
    String name,
    String brand,
    double price,
    double discountPrice,
    int stock,
    String? description,
    int reviewCount,
    Map<String, dynamic>? features,
    bool isActive,
    int favoriteCount,
    DateTime createdAt,
    DateTime updatedAt,
    String mainPictureUrl,
  });
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? brand = null,
    Object? price = null,
    Object? discountPrice = null,
    Object? stock = null,
    Object? description = freezed,
    Object? reviewCount = null,
    Object? features = freezed,
    Object? isActive = null,
    Object? favoriteCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? mainPictureUrl = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            brand:
                null == brand
                    ? _value.brand
                    : brand // ignore: cast_nullable_to_non_nullable
                        as String,
            price:
                null == price
                    ? _value.price
                    : price // ignore: cast_nullable_to_non_nullable
                        as double,
            discountPrice:
                null == discountPrice
                    ? _value.discountPrice
                    : discountPrice // ignore: cast_nullable_to_non_nullable
                        as double,
            stock:
                null == stock
                    ? _value.stock
                    : stock // ignore: cast_nullable_to_non_nullable
                        as int,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            reviewCount:
                null == reviewCount
                    ? _value.reviewCount
                    : reviewCount // ignore: cast_nullable_to_non_nullable
                        as int,
            features:
                freezed == features
                    ? _value.features
                    : features // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            favoriteCount:
                null == favoriteCount
                    ? _value.favoriteCount
                    : favoriteCount // ignore: cast_nullable_to_non_nullable
                        as int,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            mainPictureUrl:
                null == mainPictureUrl
                    ? _value.mainPictureUrl
                    : mainPictureUrl // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String brand,
    double price,
    double discountPrice,
    int stock,
    String? description,
    int reviewCount,
    Map<String, dynamic>? features,
    bool isActive,
    int favoriteCount,
    DateTime createdAt,
    DateTime updatedAt,
    String mainPictureUrl,
  });
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? brand = null,
    Object? price = null,
    Object? discountPrice = null,
    Object? stock = null,
    Object? description = freezed,
    Object? reviewCount = null,
    Object? features = freezed,
    Object? isActive = null,
    Object? favoriteCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? mainPictureUrl = null,
  }) {
    return _then(
      _$ProductImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        brand:
            null == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                    as String,
        price:
            null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                    as double,
        discountPrice:
            null == discountPrice
                ? _value.discountPrice
                : discountPrice // ignore: cast_nullable_to_non_nullable
                    as double,
        stock:
            null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                    as int,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        reviewCount:
            null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                    as int,
        features:
            freezed == features
                ? _value._features
                : features // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        favoriteCount:
            null == favoriteCount
                ? _value.favoriteCount
                : favoriteCount // ignore: cast_nullable_to_non_nullable
                    as int,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        mainPictureUrl:
            null == mainPictureUrl
                ? _value.mainPictureUrl
                : mainPictureUrl // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl implements _Product {
  const _$ProductImpl({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.discountPrice = 0.0,
    required this.stock,
    this.description,
    this.reviewCount = 0,
    final Map<String, dynamic>? features,
    this.isActive = true,
    this.favoriteCount = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.mainPictureUrl,
  }) : _features = features;

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String brand;
  @override
  final double price;
  @override
  @JsonKey()
  final double discountPrice;
  // Varsayılan değer ekleyerek null gelme ihtimaline karşı koruma
  @override
  final int stock;
  @override
  final String? description;
  // Nullable
  @override
  @JsonKey()
  final int reviewCount;
  // Varsayılan değer ekleyerek null gelme ihtimaline karşı koruma
  final Map<String, dynamic>? _features;
  // Varsayılan değer ekleyerek null gelme ihtimaline karşı koruma
  @override
  Map<String, dynamic>? get features {
    final value = _features;
    if (value == null) return null;
    if (_features is EqualUnmodifiableMapView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // Nullable Map
  @override
  @JsonKey()
  final bool isActive;
  // Varsayılan değer
  @override
  @JsonKey()
  final int favoriteCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String mainPictureUrl;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, brand: $brand, price: $price, discountPrice: $discountPrice, stock: $stock, description: $description, reviewCount: $reviewCount, features: $features, isActive: $isActive, favoriteCount: $favoriteCount, createdAt: $createdAt, updatedAt: $updatedAt, mainPictureUrl: $mainPictureUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.discountPrice, discountPrice) ||
                other.discountPrice == discountPrice) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.favoriteCount, favoriteCount) ||
                other.favoriteCount == favoriteCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.mainPictureUrl, mainPictureUrl) ||
                other.mainPictureUrl == mainPictureUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    brand,
    price,
    discountPrice,
    stock,
    description,
    reviewCount,
    const DeepCollectionEquality().hash(_features),
    isActive,
    favoriteCount,
    createdAt,
    updatedAt,
    mainPictureUrl,
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product implements Product {
  const factory _Product({
    required final int id,
    required final String name,
    required final String brand,
    required final double price,
    final double discountPrice,
    required final int stock,
    final String? description,
    final int reviewCount,
    final Map<String, dynamic>? features,
    final bool isActive,
    final int favoriteCount,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final String mainPictureUrl,
  }) = _$ProductImpl;

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get brand;
  @override
  double get price;
  @override
  double get discountPrice; // Varsayılan değer ekleyerek null gelme ihtimaline karşı koruma
  @override
  int get stock;
  @override
  String? get description; // Nullable
  @override
  int get reviewCount; // Varsayılan değer ekleyerek null gelme ihtimaline karşı koruma
  @override
  Map<String, dynamic>? get features; // Nullable Map
  @override
  bool get isActive; // Varsayılan değer
  @override
  int get favoriteCount;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get mainPictureUrl;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
