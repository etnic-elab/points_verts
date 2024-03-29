import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

import 'cache_http_file_service.dart';

abstract class AbstractCacheManager {
  CacheManager? instance;

  String get key;
  String get contentType;
  Duration get cacheDuration;

  CacheManager getInstance() {
    return instance ??= CacheManager(
      Config(
        key,
        fileService: CacheHttpFileService(cacheDuration),
      ),
    );
  }

  Future<http.Response> getData(String url) async {
    var file = await getInstance().getSingleFile(url);
    if (await file.exists()) {
      var res = await file.readAsString();
      return http.Response(res, 200, headers: {'content-type': contentType});
    }
    return http.Response("not found", 404);
  }
}
