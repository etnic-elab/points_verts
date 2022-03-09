import 'package:geolocator/geolocator.dart';

Future<LocationPermission> checkLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openLocationSettings();
    return permission;
  } else if (permission == LocationPermission.denied) {
    return Geolocator.requestPermission();
  } else {
    return permission;
  }
}
