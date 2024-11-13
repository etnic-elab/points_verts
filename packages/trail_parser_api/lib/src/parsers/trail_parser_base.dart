import 'package:trail_parser_api/trail_parser_api.dart' show TrailInfo;

abstract class TrailParser {
  Future<TrailInfo> parse(String content);
  bool canHandle(String fileExtension);
}

class TrailParserException implements Exception {}
