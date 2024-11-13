import 'dart:async' show FutureOr;

import 'package:json_map_typedef/json_map_typedef.dart' show JsonMap;
import 'package:persistent_storage_manager/persistent_storage_manager.dart'
    show PersistentStorageManager;
import 'package:trail_parser_api/trail_parser_api.dart' show TrailInfo;

class TrailParserCacheManager extends PersistentStorageManager<TrailInfo> {
  TrailParserCacheManager({
    required super.prefs,
  }) : super(
          persistentKey: 'trail_parser_cache',
          defaultExpiration: const Duration(hours: 12),
        );

  Future<TrailInfo> fetchTrail(
    String url, {
    required FutureOr<TrailInfo> Function() defaultValueProvider,
  }) async {
    final cacheKey = url;

    final trail = await getValue(
      key: cacheKey,
      defaultValueProvider: defaultValueProvider,
    );

    if (trail == null) {
      throw StateError(
        'Failed to fetch trail for url $url',
      );
    }

    return trail;
  }

  @override
  TrailInfo fromJson(dynamic json) {
    if (json is JsonMap) {
      return TrailInfo.fromJson(json);
    }
    throw FormatException('Expected a JsonMap, but got ${json.runtimeType}');
  }

  @override
  JsonMap toJson(TrailInfo value) => value.toJson();
}
