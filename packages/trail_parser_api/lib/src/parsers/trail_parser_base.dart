import 'package:trail_parser_api/trail_parser_api.dart' show Trail;

abstract class TrailParser {
  Future<Trail> parse(String content);
  bool canHandle(String fileExtension);
}

class TrailParserException implements Exception {}
