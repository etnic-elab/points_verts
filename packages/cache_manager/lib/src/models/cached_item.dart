import 'package:json_map_typedef/json_map_typedef.dart';

class CachedItem<T> {
  CachedItem({
    required this.data,
    required this.createdOn,
    required this.expiration,
  });

  final T data;
  final DateTime createdOn;
  final DateTime? expiration;

  bool isExpired() {
    if (expiration == null) return false;

    return DateTime.now().isAfter(expiration!);
  }

  Map<String, dynamic> toJson() => {
        'data': data,
        'createdOn': createdOn.toIso8601String(),
        'expiration': expiration?.toIso8601String(),
      };

  static CachedItem<T> fromJson<T>(
    JsonMap json,
    T Function(dynamic json) fromJsonT,
  ) {
    return CachedItem<T>(
      data: fromJsonT(json['data']),
      createdOn: DateTime.parse(json['createdOn'] as String),
      expiration: json['expiration'] != null
          ? DateTime.parse(json['expiration'] as String)
          : null,
    );
  }
}
