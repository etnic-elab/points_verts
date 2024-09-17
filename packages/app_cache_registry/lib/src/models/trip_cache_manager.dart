// Specific implementation for Trips cache
import 'package:cache_manager/cache_manager.dart';
import 'package:jsonable/jsonable.dart';
import 'package:maps_api/maps_api.dart';

class TripsCacheManager extends CacheManager<List<TripInfo>> {
  TripsCacheManager()
      : super(
          persistentCacheKey: 'trips_cache',
          defaultExpiration: const Duration(days: 31),
          maxCacheSize: 50,
        );

  @override
  List<TripInfo> fromJsonT(dynamic json) {
    if (json is List) {
      return json.map((item) => TripInfo.fromJson(item as JsonMap)).toList();
    }
    throw FormatException('Expected a List, but got ${json.runtimeType}');
  }

  String generateCacheKey(Geolocation origin, List<Geolocation> destinations) {
    return '${origin}_${destinations.map((d) => d.toString()).join('_')}';
  }
}
