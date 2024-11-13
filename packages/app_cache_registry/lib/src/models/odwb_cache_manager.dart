import 'dart:async' show FutureOr;

import 'package:intl/intl.dart' show DateFormat;
import 'package:json_map_typedef/json_map_typedef.dart' show JsonMap;
import 'package:odwb_points_verts_api/odwb_points_verts_api.dart'
    show OdwbPointVert;
import 'package:persistent_storage_manager/persistent_storage_manager.dart'
    show PersistentStorageManager;

class OdwbCacheManager extends PersistentStorageManager<List<OdwbPointVert>> {
  OdwbCacheManager({
    required super.prefs,
  }) : super(
          persistentKey: 'odwb_cache',
          defaultExpiration: const Duration(minutes: 10),
        );

  Future<List<OdwbPointVert>> fetchPointsVerts({
    required FutureOr<List<OdwbPointVert>> Function() defaultValueProvider,
  }) async {
    final cacheKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final pointsVerts = await getValue(
      key: cacheKey,
      defaultValueProvider: defaultValueProvider,
    );

    if (pointsVerts == null) {
      throw StateError(
        'Failed to fetch points verts',
      );
    }

    return pointsVerts;
  }

  @override
  List<OdwbPointVert> fromJson(dynamic json) {
    if (json is List) {
      return json
          .map((item) => OdwbPointVert.fromJson(item as JsonMap))
          .toList();
    }
    throw FormatException('Expected a List, but got ${json.runtimeType}');
  }

  @override
  List<JsonMap> toJson(List<OdwbPointVert> value) =>
      value.map((v) => v.toJson()).toList();
}
