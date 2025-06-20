// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: json['userId'] as String,
      title: json['title'] as String,
      fullAddress: json['fullAddress'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipcode: json['zipcode'] as String,
      country: json['country'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'fullAddress': instance.fullAddress,
      'city': instance.city,
      'state': instance.state,
      'zipcode': instance.zipcode,
      'country': instance.country,
      'isDefault': instance.isDefault,
    };
