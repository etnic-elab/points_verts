class Coordinates {
  Coordinates({this.latitude, this.longitude});

  double latitude;
  double longitude;

  @override
  String toString() {
    return 'Coordinates{latitude: $latitude, longitude: $longitude}';
  }
}
