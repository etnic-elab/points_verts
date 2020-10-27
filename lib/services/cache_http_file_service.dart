import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class CacheHttpFileService extends FileService {
  http.Client _httpClient;
  int _maxAge;
  CacheHttpFileService(Duration duration, {http.Client httpClient}) {
    _httpClient = httpClient ?? http.Client();
    _maxAge = duration.inSeconds;
  }

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String> headers = const {}}) async {
    final req = http.Request('GET', Uri.parse(url));
    req.headers.addAll(headers);

    final httpResponse = await _httpClient.send(req);
    httpResponse.headers.addAll({'cache-control': 'max-age=$_maxAge'});

    return HttpGetResponse(httpResponse);
  }
}
