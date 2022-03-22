import 'abstract_cache_manager.dart';

class TripCacheManager extends AbstractCacheManager {
  TripCacheManager._();
  static final TripCacheManager trip = TripCacheManager._();

  @override
  String get key => 'tripCache';

  @override
  String get contentType => 'application/json; charset=utf-8';

  @override
  Duration get cacheDuration => const Duration(days: 30);
}
