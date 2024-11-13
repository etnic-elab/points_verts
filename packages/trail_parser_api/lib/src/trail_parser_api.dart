import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:trail_parser_api/trail_parser_api.dart';

/// {@template trail_service}
/// A service that provides functionality to parse and analyze trail files from various formats
/// including GPX and KML.
/// {@endtemplate}
class TrailParserApi {
  /// {@macro trail_service}
  TrailParserApi({
    http.Client? httpClient,
    List<TrailParser>? parsers,
  })  : _httpClient = httpClient ?? http.Client(),
        _parsers = parsers ?? [GpxParser(), KmlParser()];

  final http.Client _httpClient;
  final List<TrailParser> _parsers;

  /// Fetches and parses a trail file from the provided URL.
  ///
  /// Supports various file formats including GPX and KML.
  /// Throws [TrailParserApiException] if the file cannot be fetched or parsed.
  /// Throws [UnsupportedFormatException] if the file format is not supported.
  /// Throws [TrailParserException] if a problem was encountered during parsing
  ///
  /// [url] The URL of the trail file to parse.
  Future<TrailInfo> parseTrailFromUrl(String url) async {
    final extension = path.extension(url).toLowerCase();

    final parser = _getParserForExtension(extension);

    try {
      final response = await _httpClient.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw TrailParserApiException();
      }

      return await parser.parse(response.body);
    } catch (e) {
      throw TrailParserApiException();
    }
  }

  /// Parses trail content from a string.
  ///
  /// Requires the file extension to determine the appropriate parser.
  /// Throws [TrailParserApiException] if the content cannot be parsed.
  /// Throws [UnsupportedFormatException] if the file format is not supported.
  /// Throws [TrailParserException] if a problem was encountered during parsing
  ///
  /// [content] The string content of the trail file.
  /// [fileExtension] The extension of the file format (e.g., '.gpx', '.kml').
  Future<TrailInfo> parseTrailFromContent(
    String content,
    String fileExtension,
  ) async {
    final parser = _getParserForExtension(fileExtension);

    try {
      return await parser.parse(content);
    } catch (e) {
      throw TrailParserApiException();
    }
  }

  /// Returns the appropriate parser for the given file extension.
  ///
  /// Throws [UnsupportedFormatException] if no parser is found for the extension.
  TrailParser _getParserForExtension(String extension) {
    return _parsers.firstWhere(
      (parser) => parser.canHandle(extension),
      orElse: () => throw UnsupportedFormatException(extension),
    );
  }
}

class TrailParserApiException implements Exception {}

/// Exception thrown when an unsupported file format is encountered
class UnsupportedFormatException implements Exception {
  /// {@macro unsupported_format_exception}
  const UnsupportedFormatException(this.extension);

  /// The unsupported file extension
  final String extension;

  @override
  String toString() =>
      'UnsupportedFormatException: Unsupported file format: $extension';
}
