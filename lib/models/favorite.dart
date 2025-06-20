import 'package:freezed_annotation/freezed_annotation.dart';
part 'favorite.freezed.dart';
part 'favorite.g.dart';

@freezed
class Favorite with _$Favorite {
  const factory Favorite({required String userId, required int productId}) =
      _Favorite;

  factory Favorite.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFromJson(json);
}
