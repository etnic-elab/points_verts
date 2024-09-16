/// Represents a trip with distance and duration information.
class TripInfo {
  /// Creates a [TripInfo] instance.
  ///
  /// [distance] is the distance of the trip.
  /// [duration] is the duration of the trip.
  TripInfo({required this.distance, required this.duration});

  factory TripInfo.fromJson(Map<String, dynamic> json) => TripInfo(
        distance: json['distance'] as num,
        duration: json['duration'] as num,
      );

  /// The distance of the trip.
  final num distance;

  /// The duration of the trip.
  final num duration;

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'duration': duration,
      };
}
