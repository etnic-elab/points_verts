import 'dart:async' show FutureOr;

import 'package:maps_api/maps_api.dart' show MapType;
import 'package:persistent_storage_manager/persistent_storage_manager.dart'
    show PersistentStorageManager;

class DefaultMapTypeStorage extends PersistentStorageManager<MapType> {
  DefaultMapTypeStorage({
    required super.prefs,
  }) : super(
          persistentKey: 'default_map_type',
        );

  Future<MapType> get({
    required FutureOr<MapType> Function() defaultValueProvider,
  }) async {
    final mapType = await getValue(defaultValueProvider: defaultValueProvider);

    if (mapType == null) {
      throw StateError('Failed to fetch default map type');
    }

    return mapType;
  }

  @override
  MapType fromJson(dynamic json) => MapType.fromJson(json);

  @override
  String toJson(MapType value) => value.toJson();
}
