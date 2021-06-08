import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

import 'cache_http_file_service.dart';

const Duration cacheDuration = Duration(hours: 3);

class WeatherCacheManager {
  static const key = 'weatherCache';
  static CacheManager instance = CacheManager(
    Config(
      key,
      fileService: CacheHttpFileService(cacheDuration),
    ),
  );

  static Future<http.Response> getData(String url) async {
    var file = await instance.getSingleFile(url);
    if (await file.exists()) {
      var res = await file.readAsString();
      return http.Response(res, 200);
    }
    return http.Response("not found", 404);
  }
}
