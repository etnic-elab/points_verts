import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class WeatherCacheManager extends BaseCacheManager {
  static const key = "weatherCache";

  static WeatherCacheManager _instance;

  factory WeatherCacheManager() {
    if (_instance == null) {
      _instance = new WeatherCacheManager._();
    }
    return _instance;
  }

  WeatherCacheManager._()
      : super(key,
            maxAgeCacheObject: Duration(hours: 3),
            fileFetcher: _customHttpGetter);

  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return path.join(directory.path, key);
  }

  static Future<FileFetcherResponse> _customHttpGetter(String url,
      {Map<String, String> headers}) async {
    return HttpFileFetcherResponse(await http.get(url, headers: headers));
  }

  Future<http.Response> getData(String url, Map<String, String> headers) async {
    var file = await _instance.getSingleFile(url, headers: headers);
    if (file != null && await file.exists()) {
      var res = await file.readAsString();
      return http.Response(res, 200);
    }
    return http.Response(null, 404);
  }
}
