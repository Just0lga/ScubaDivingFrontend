import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
class Address with _$Address {
  const factory Address({
    int? id, // Yeni adres eklerken null olabilir, güncellerken dolu gelir
    required String userId,
    required String title,
    required String fullAddress,
    required String city,
    required String state,
    required String zipcode,
    required String country,
    @Default(false)
    bool isDefault, // Varsayılan olarak false, belirtilmezse false olur
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}
