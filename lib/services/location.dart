import 'package:geolocator/geolocator.dart';

Future<LocationPermission> checkLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    return Geolocator.requestPermission();
  }

  return permission;
}
