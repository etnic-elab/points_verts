import 'package:adeps_website/src/models/models.dart';
import 'package:json_map_typedef/json_map_typedef.dart';

class WebsitePointVert {
  WebsitePointVert({
    required this.id,
    required this.statut,
  });

  factory WebsitePointVert.fromJson(Map<String, dynamic> json) {
    return WebsitePointVert(
      id: json['id'] as int,
      statut: WebsitePointVertStatus.values.firstWhere(
        (status) => status.name == json['statut'],
        orElse: () => WebsitePointVertStatus.unknown,
      ),
    );
  }

  /// Creates a WebsitePointVert from raw website data lines
  ///
  /// Expects an array of strings containing website data where:
  /// - index + 0: contains the ID
  /// - index + 9: contains the status
  factory WebsitePointVert.fromWebsiteData(List<String> lines, int startIndex) {
    if (startIndex + 10 >= lines.length) {
      throw ArgumentError('Invalid data: not enough lines');
    }

    final id = int.parse(lines[startIndex]);
    final status = lines[startIndex + 9];

    return WebsitePointVert(
      id: id,
      statut: WebsitePointVertStatus.fromWebsiteData(status),
    );
  }

  final int id;
  final WebsitePointVertStatus statut;

  JsonMap toJson() {
    return {
      'id': id,
      'statut': statut.name,
    };
  }

  @override
  String toString() => 'WebsitePointVert(id: $id, statut: $statut)';
}
