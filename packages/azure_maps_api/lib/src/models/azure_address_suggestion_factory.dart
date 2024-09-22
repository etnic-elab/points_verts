import 'package:jsonable/jsonable.dart';
import 'package:maps_api/maps_api.dart';

class AzureAddressSuggestionFactory {
  static AddressSuggestion fromJson(Map<String, dynamic> json) {
    final address = json['address'] as JsonMap;
    final position = json['position'] as JsonMap;

    final geolocation = Geolocation(
      longitude: position['lon'] as double,
      latitude: position['lat'] as double,
    );

    String mainText;
    if (json['type'] == 'POI') {
      mainText = json['poi']['name'] as String? ?? '';
    } else if (json['type'] == 'Street') {
      mainText = address['streetName'] as String? ?? '';
    } else {
      mainText =
          '${address['streetName'] ?? ''} ${address['streetNumber'] ?? ''}'
              .trim();
    }

    return AddressSuggestion(
      mainText: mainText,
      description: address['freeformAddress'] as String? ?? '',
      geolocation: geolocation,
    );
  }
}
