import 'package:maps_api/maps_api.dart';

class MapboxAddressSuggestionFactory {
  static AddressSuggestion fromJson(Map<String, dynamic> json) {
    final center = json['center'] as List<dynamic>;
    final geolocation = Geolocation(
      latitude: center[1] as double,
      longitude: center[0] as double,
    );

    return AddressSuggestion(
      mainText: json['text'] as String,
      description: json['place_name'] as String,
      placeId: json['id'] as String,
      geolocation: geolocation,
    );
  }
}
