import 'package:equatable/equatable.dart';
import 'package:jsonable/jsonable.dart' show JsonMap;
import 'package:maps_api/src/models/models.dart' show Geolocation;

/// Represents a trip with distance, duration, origin, and destination information.
class TripInfo extends Equatable {
  /// Creates a [TripInfo] instance.
  ///
  /// [distance] is the distance of the trip.
  /// [duration] is the duration of the trip.
  /// [origin] is the starting point of the trip.
  /// [destination] is the end point of the trip.
  const TripInfo({
    required this.distance,
    required this.duration,
    required this.origin,
    required this.destination,
  });

  /// Creates a [TripInfo] instance from a JSON map.
  factory TripInfo.fromJson(JsonMap json) => TripInfo(
        distance: json['distance'] as num,
        duration: json['duration'] as num,
        origin: Geolocation.fromJson(json['origin'] as JsonMap),
        destination: Geolocation.fromJson(json['destination'] as JsonMap),
      );

  /// The distance of the trip.
  final num distance;

  /// The duration of the trip.
  final num duration;

  /// The origin (starting point) of the trip.
  final Geolocation origin;

  /// The destination (end point) of the trip.
  final Geolocation destination;

  /// Converts the [TripInfo] instance to a JSON map.
  JsonMap toJson() => {
        'distance': distance,
        'duration': duration,
        'origin': origin.toJson(),
        'destination': destination.toJson(),
      };

  /// Returns a list of properties used for equality comparison.
  @override
  List<Object> get props => [distance, duration, origin, destination];
}
