import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class CacheHttpFileService extends FileService {
  late http.Client _httpClient;
  int? _maxAge;

  CacheHttpFileService(Duration duration, {http.Client? httpClient}) {
    _httpClient = httpClient ?? http.Client();
    _maxAge = duration.inSeconds;
  }

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers}) async {
    final req = http.Request('GET', Uri.parse(url));
    if (headers != null) {
      req.headers.addAll(headers);
    }
    final httpResponse = await _httpClient.send(req);
    httpResponse.headers
        .addAll({HttpHeaders.cacheControlHeader: 'max-age=$_maxAge'});

    return HttpGetResponse(httpResponse);
  }
}
