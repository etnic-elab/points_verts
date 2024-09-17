import 'package:jsonable/jsonable.dart';
import 'package:maps_api/maps_api.dart';

class GoogleTripInfoFactory {
  static TripInfo fromJson(JsonMap json) {
    if (json['status'] != 'OK') {
      throw const FormatException('Invalid status in Google Maps API response');
    }

    final distance = json['distance'] as JsonMap;
    final duration = json['duration'] as JsonMap;

    return TripInfo(
      distance: distance['value'] as num,
      duration: duration['value'] as num,
    );
  }
}
