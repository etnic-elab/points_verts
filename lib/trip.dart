class Trip {
  Trip({this.distance, this.duration});

  double distance;
  double duration;

  @override
  String toString() {
    return 'Trip{distance: $distance, duration: $duration}';
  }


}
