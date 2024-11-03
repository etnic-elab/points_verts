// Specific implementation for Trips cache
import 'package:cache_manager/cache_manager.dart';
import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:maps_api/maps_api.dart';

class TripsCacheManager extends CacheManager<TripInfo> {
  TripsCacheManager() : super(persistentCacheKey: 'trips_cache');

  @override
  TripInfo fromJsonT(dynamic json) {
    if (json is JsonMap) {
      return TripInfo.fromJson(json);
    }
    throw FormatException('Expected a JsonMap, but got ${json.runtimeType}');
  }

  String generateCacheKey(Geolocation origin, Geolocation destination) {
    return '${origin}_$destination';
  }

  Future<List<TripInfo>> getTrips(
    Geolocation origin,
    List<Geolocation> destinations,
    Future<List<TripInfo>> Function(Geolocation, List<Geolocation>)
        fetchFunction, {
    required DateTime expiration,
  }) async {
    final result = <TripInfo>[];
    final missingDestinations = <Geolocation>[];

    for (final destination in destinations) {
      final cacheKey = generateCacheKey(origin, destination);
      try {
        final cachedTrip = await get(cacheKey, () => throw CacheMiss());
        result.add(cachedTrip);
      } on CacheMiss {
        missingDestinations.add(destination);
      }
    }

    if (missingDestinations.isNotEmpty) {
      final newTrips = await fetchFunction(origin, missingDestinations);
      for (final trip in newTrips) {
        final cacheKey = generateCacheKey(trip.origin, trip.destination);
        await set(cacheKey, trip, expirationDateTime: expiration);
        result.add(trip);
      }
    }

    return result;
  }
}
