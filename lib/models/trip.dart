class Trip {
  Trip({required this.distance, required this.duration});

  double? distance;
  double? duration;

  @override
  String toString() {
    return 'Trip{distance: $distance, duration: $duration}';
  }
}
