import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:maps_api/maps_api.dart';

class GoogleTripInfoFactory {
  static TripInfo fromJson(
    JsonMap json, {
    required Geolocation origin,
    required Geolocation destination,
  }) {
    if (json['status'] != 'OK') {
      throw const FormatException('Invalid status in Google Maps API response');
    }

    final distance = json['distance'] as JsonMap;
    final duration = json['duration'] as JsonMap;

    return TripInfo(
      origin: origin,
      destination: destination,
      distance: distance['value'] as num,
      duration: duration['value'] as num,
    );
  }
}
