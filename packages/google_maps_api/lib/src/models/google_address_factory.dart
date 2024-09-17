import 'package:jsonable/jsonable.dart';
import 'package:maps_api/maps_api.dart';

class GoogleAddressFactory {
  static Address fromJson(JsonMap json) {
    final placeResult = json['result'] as JsonMap;
    final geometry = placeResult['geometry'] as JsonMap;
    final location = geometry['location'] as JsonMap;

    return Address(
      mainText: placeResult['formatted_address'] as String,
      geolocation: Geolocation(
        latitude: location['lat'] as double,
        longitude: location['lng'] as double,
      ),
    );
  }
}
