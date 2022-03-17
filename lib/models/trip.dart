class Trip {
  Trip({required this.distance, required this.duration});

  num? distance;
  num? duration;

  @override
  String toString() {
    return 'Trip{distance: $distance, duration: $duration}';
  }
}
