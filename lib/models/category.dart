import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart'; // freezy kodu otomatik olarak burada oluşturulacak
part 'category.g.dart'; // json_serializable kodu otomatik olarak burada oluşturulacak

@freezed
class Category with _$Category {
  const factory Category({
    int? id,
    required String name,
    int? parentId,
    String? image,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
