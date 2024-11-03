import 'package:geolocator/geolocator.dart';

Future<LocationPermission> checkLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  //TODO: deniedForever should not open locationSettings
  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openLocationSettings();
    return permission;
  } else if (permission == LocationPermission.denied) {
    return Geolocator.requestPermission();
  } else {
    return permission;
  }
}
