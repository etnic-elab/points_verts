class Coordinates {
  Coordinates({required this.latitude, required this.longitude});

  double latitude;
  double longitude;

  @override
  String toString() {
    return 'Coordinates{latitude: $latitude, longitude: $longitude}';
  }
}
