import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

@freezed
class Cart with _$Cart {
  const factory Cart({
    required String userId,
    required int productId,
    required int quantity,
  }) = _Cart; // Burası düzeltildi: _Cart oldu

  factory Cart.fromJson(Map<String, dynamic> json) =>
      _$CartFromJson(json); // Burası düzeltildi: _$CartFromJson oldu
}
