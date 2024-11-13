enum MapType {
  road,
  satellite,
  terrain,
  hybrid;

  static MapType fromJson(dynamic json) {
    if (json is String) {
      return MapType.values.firstWhere(
        (type) => type.name == json.toLowerCase(),
        orElse: () => throw FormatException('Invalid map type: $json'),
      );
    } else if (json is int) {
      if (json >= 0 && json < MapType.values.length) {
        return MapType.values[json];
      }
      throw FormatException('Invalid map type index: $json');
    }
    throw FormatException(
      'Expected a String or int, but got ${json.runtimeType}',
    );
  }

  String toJson() => name;
}
