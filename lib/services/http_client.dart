import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

const _trustedHosts = ['www.am-sport.cfwb.be'];

http.Client createTrustedHttpClient() {
  final ioClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return _trustedHosts.contains(host);
    };
  return IOClient(ioClient);
}
