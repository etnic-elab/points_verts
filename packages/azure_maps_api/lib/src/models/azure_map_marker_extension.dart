import 'package:maps_api/maps_api.dart';

extension AzureMapMarkerExtension on MapMarker {
  String toAzureEncode() {
    final style = iconUrl != null ? 'custom' : 'default';
    final location = '${geolocation.longitude} ${geolocation.latitude}';
    final iconUrlPart = iconUrl ?? '';
    return '$style||$location||$iconUrlPart';
  }
}
