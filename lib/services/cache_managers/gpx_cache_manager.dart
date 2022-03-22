import 'package:points_verts/services/cache_managers/abstract_cache_manager.dart';

class GpxCacheManager extends AbstractCacheManager {
  GpxCacheManager._();
  static final GpxCacheManager gpx = GpxCacheManager._();

  @override
  String get key => 'gpxCache';

  @override
  String get contentType => 'application/binary; charset=utf-8';

  @override
  Duration get cacheDuration => const Duration(hours: 24);
}
