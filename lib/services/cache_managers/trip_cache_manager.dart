import 'package:points_verts/services/cache_managers/abstract_cache_manager.dart';

class TripCacheManager extends AbstractCacheManager {
  TripCacheManager._();
  static final TripCacheManager trip = TripCacheManager._();

  @override
  String getKey() {
    return key ??= "tripCache";
  }

  @override
  Duration getCacheDuration() {
    return cacheDuration ??= const Duration(days: 30);
  }
}
