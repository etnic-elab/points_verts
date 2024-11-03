import 'package:cache_manager/cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:json_map_typedef/json_map_typedef.dart' show JsonMap;
import 'package:odwb_points_verts_api/odwb_points_verts_api.dart';

class OdwbCacheManager extends CacheManager<List<OdwbPointVert>> {
  OdwbCacheManager()
      : super(
          persistentCacheKey: 'odwb_cache',
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

  // TODO(msimonart): Change the generateCacheKey.
  String generateCacheKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}
