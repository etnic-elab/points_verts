import 'package:jsonable/jsonable.dart';

class CachedItem<T> {
  CachedItem({
    required this.data,
    required this.timestamp,
    required this.expiration,
  });

  final T data;
  final DateTime timestamp;
  final Duration? expiration;

  bool isExpired() {
    if (expiration == null) return false;

    return DateTime.now().difference(timestamp) > expiration!;
  }

  Map<String, dynamic> toJson() => {
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'expiration': expiration?.inSeconds,
      };

  static CachedItem<T> fromJson<T>(
    JsonMap json,
    T Function(dynamic json) fromJsonT,
  ) {
    return CachedItem<T>(
      data: fromJsonT(json['data']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      expiration: json['expiration'] != null
          ? Duration(seconds: json['expiration'] as int)
          : null,
    );
  }
}
