import 'package:cache_manager/cache_manager.dart';
import 'package:json_map_typedef/json_map_typedef.dart' show JsonMap;
import 'package:odwb_points_verts_api/odwb_points_verts_api.dart';

class AdepsWebsiteCacheManager extends CacheManager<List<OdwbPointVert>> {
  AdepsWebsiteCacheManager()
      : super(
          persistentCacheKey: 'adeps_website_cache',
          defaultExpiration: const Duration(minutes: 10),
        );

  @override
  List<OdwbPointVert> fromJsonT(dynamic json) {
    if (json is List) {
      return json
          .map((item) => OdwbPointVert.fromJson(item as JsonMap))
          .toList();
    }
    throw FormatException('Expected a List, but got ${json.runtimeType}');
  }

  String generateCacheKey(DateTime date) {
    return date.toIso8601String();
  }
}
