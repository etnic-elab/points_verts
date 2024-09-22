import 'package:equatable/equatable.dart';

/// Represents a geographical location with coordinates.
class Geolocation extends Equatable {
  /// Creates a [Geolocation] instance.
  ///
  /// [longitude] is the east-west position on the Earth's surface.
  /// [latitude] is the north-south position on the Earth's surface.
  const Geolocation({
    required this.longitude,
    required this.latitude,
  });

  /// Creates a [Geolocation] instance from a JSON map.
  factory Geolocation.fromJson(Map<String, dynamic> json) {
    return Geolocation(
      longitude: json['longitude'] as double,
      latitude: json['latitude'] as double,
    );
  }

  /// The longitude coordinate of the location.
  final double longitude;

  /// The latitude coordinate of the location.
  final double latitude;

  /// Returns a string representation of the [Geolocation] instance.
  ///
  /// The string includes the longitude and latitude coordinates
  /// formatted to 6 decimal places.
  @override
  String toString() {
    return 'Geolocation(longitude: ${longitude.toStringAsFixed(6)}, '
        'latitude: ${latitude.toStringAsFixed(6)})';
  }

  /// Returns a list of properties used for equality comparison.
  @override
  List<Object> get props => [longitude, latitude];

  /// Converts the [Geolocation] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'longitude': longitude,
      'latitude': latitude,
    };
  }
}
