import 'package:json_map_typedef/json_map_typedef.dart';

class CachedValue<T> {
  CachedValue({
    required this.data,
    required this.createdOn,
    this.expiration,
  });

  final T data;
  final DateTime createdOn;
  final DateTime? expiration;

  bool isExpired() {
    if (expiration == null) return false;
    return DateTime.now().isAfter(expiration!);
  }

  JsonMap toJson(
    dynamic Function(T value) dataToJson,
  ) =>
      {
        'data': dataToJson(data),
        'createdOn': createdOn.toIso8601String(),
        'expiration': expiration?.toIso8601String(),
      };

  static CachedValue<T> fromJson<T>(
    JsonMap json,
    T Function(dynamic json) dataFromJson,
  ) {
    return CachedValue<T>(
      data: dataFromJson(json['data']),
      createdOn: DateTime.parse(json['createdOn'] as String),
      expiration: json['expiration'] != null
          ? DateTime.parse(json['expiration'] as String)
          : null,
    );
  }
}
