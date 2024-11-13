import 'dart:async' show FutureOr;

import 'package:adeps_website_api/adeps_website_api.dart' show WebsitePointVert;
import 'package:intl/intl.dart' show DateFormat;
import 'package:json_map_typedef/json_map_typedef.dart' show JsonMap;
import 'package:persistent_storage_manager/persistent_storage_manager.dart'
    show PersistentStorageManager;

class AdepsWebsiteCacheManager
    extends PersistentStorageManager<List<WebsitePointVert>> {
  AdepsWebsiteCacheManager({
    required super.prefs,
  }) : super(
          persistentKey: 'adeps_website_cache',
          defaultExpiration: const Duration(minutes: 10),
        );

  Future<List<WebsitePointVert>> fetchPointsVerts(
    DateTime date, {
    required FutureOr<List<WebsitePointVert>> Function() defaultValueProvider,
  }) async {
    final cacheKey = DateFormat('yyyy-MM-dd').format(date);

    final pointsVerts = await getValue(
      key: cacheKey,
      defaultValueProvider: defaultValueProvider,
    );

    if (pointsVerts == null) {
      throw StateError('Failed to fetch points verts for date $date');
    }

    return pointsVerts;
  }

  @override
  List<WebsitePointVert> fromJson(dynamic json) {
    if (json is List) {
      return json
          .map((item) => WebsitePointVert.fromJson(item as JsonMap))
          .toList();
    }
    throw FormatException('Expected a List, but got ${json.runtimeType}');
  }

  @override
  List<JsonMap> toJson(List<WebsitePointVert> value) =>
      value.map((v) => v.toJson()).toList();
}
