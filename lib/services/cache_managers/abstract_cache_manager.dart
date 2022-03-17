import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

import 'cache_http_file_service.dart';

abstract class AbstractCacheManager {
  String? key;
  Duration? cacheDuration;
  CacheManager? instance;

  String getKey();
  Duration getCacheDuration();

  CacheManager getInstance() {
    return instance ??= CacheManager(
      Config(
        getKey(),
        fileService: CacheHttpFileService(getCacheDuration()),
      ),
    );
  }

  Future<http.Response> getData(String url) async {
    var file = await getInstance().getSingleFile(url);
    if (await file.exists()) {
      var res = await file.readAsString();
      return http.Response(res, 200,
          headers: {'content-type': 'application/json; charset=utf-8'});
    }
    return http.Response("not found", 404);
  }
}
