import 'dart:async' show FutureOr;

import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:maps_api/maps_api.dart' show Geolocation, TripInfo;
import 'package:persistent_storage_manager/persistent_storage_manager.dart'
    show PersistentStorageManager;

class TripsCacheManager extends PersistentStorageManager<TripInfo> {
  TripsCacheManager({
    required super.prefs,
  }) : super(persistentKey: 'trips_cache');

  String _generateCacheKey(Geolocation origin, Geolocation destination) {
    return '${origin}_$destination';
  }

  Future<List<TripInfo>> fetchTrips({
    required Geolocation origin,
    required List<Geolocation> destinations,
    required DateTime expiration,
    required FutureOr<List<TripInfo>> Function(
      Geolocation origin,
      List<Geolocation> destinations,
    ) defaultValueProvider,
  }) async {
    final result = <TripInfo>[];
    final missingDestinations = <Geolocation>[];

    // Try to get each trip from cache first
    for (final destination in destinations) {
      final cacheKey = _generateCacheKey(origin, destination);
      final cachedTrip = await getCachedValue(cacheKey);

      if (cachedTrip != null) {
        result.add(cachedTrip.data);
      } else {
        missingDestinations.add(destination);
      }
    }

    // Batch fetch missing trips
    if (missingDestinations.isNotEmpty) {
      final newTrips = await defaultValueProvider(origin, missingDestinations);
      for (final trip in newTrips) {
        final cacheKey = _generateCacheKey(trip.origin, trip.destination);
        await setValue(trip, cacheKey, expirationDateTime: expiration);
        result.add(trip);
      }
    }

    return result;
  }

  @override
  TripInfo fromJson(dynamic json) {
    if (json is JsonMap) {
      return TripInfo.fromJson(json);
    }
    throw FormatException('Expected a JsonMap, but got ${json.runtimeType}');
  }

  @override
  JsonMap toJson(TripInfo value) => value.toJson();
}
