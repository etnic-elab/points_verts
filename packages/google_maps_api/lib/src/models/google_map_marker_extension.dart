import 'package:maps_api/maps_api.dart';

extension GoogleMapMarkerExtension on MapMarker {
  String toGoogleEncode() {
    return [
      'scale:${scale ?? 1}',
      'anchor:${anchor ?? 'center'}',
      if (iconUrl != null) 'icon:$iconUrl',
      '${geolocation.latitude},${geolocation.longitude}',
    ].join('|');
  }
}
