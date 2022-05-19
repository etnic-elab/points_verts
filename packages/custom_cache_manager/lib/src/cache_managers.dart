import 'dart:io';

import 'package:custom_cache_manager/src/http_file_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

abstract class Manager {
  CacheManager? _instance;

  String get key;
  String get contentType;
  Duration get cacheDuration;

  CacheManager get instance {
    return _instance ??= CacheManager(
      Config(
        key,
        fileService: HttpFileService(),
      ),
    );
  }

  Future<http.Response> getData(String url) async {
    var file = await instance.getSingleFile(url);
    if (await file.exists()) {
      var res = await file.readAsString();
      return http.Response(res, 200,
          headers: {HttpHeaders.contentTypeHeader: contentType});
    }
    return http.Response("not found", 404);
  }
}

class GpxManager extends AbstractCacheManager {
  GpxManager._();
  static final GpxManager gpx = GpxManager._();

  @override
  String get key => 'gpxCache';

  @override
  String get contentType => 'application/binary; charset=utf-8';

  @override
  Duration get cacheDuration => const Duration(hours: 24);
}
