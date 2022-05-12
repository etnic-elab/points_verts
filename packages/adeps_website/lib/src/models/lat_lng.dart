class LatLng {
  const LatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  String stringify() {
    return '$latitude,$longitude';
  }
}
