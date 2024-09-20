import 'package:jsonable/jsonable.dart';
import 'package:maps_api/maps_api.dart';

class AzureTripInfoFactory {
  static TripInfo fromJson(
    JsonMap json, {
    required Geolocation origin,
    required Geolocation destination,
  }) {
    if (json['statusCode'] != 200) {
      throw FormatException(
        'Invalid status code in Azure Maps API response: ${json['statusCode']}',
      );
    }

    final response = json['response'] as JsonMap;
    final routeSummary = response['routeSummary'] as JsonMap;

    return TripInfo(
      origin: origin,
      destination: destination,
      distance: routeSummary['lengthInMeters'] as num,
      duration: routeSummary['travelTimeInSeconds'] as num,
    );
  }
}
