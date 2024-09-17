import 'package:maps_api/maps_api.dart';

class MapboxAddressSuggestionFactory {
  static AddressSuggestion fromJson(Map<String, dynamic> json) {
    final center = json['center'] as List<double>;
    final geolocation = Geolocation(
      latitude: center[1],
      longitude: center[0],
    );

    return AddressSuggestion(
      mainText: json['text'] as String,
      description: json['place_name'] as String,
      placeId: json['id'] as String,
      geolocation: geolocation,
    );
  }
}
