/// Represents a geographical location with coordinates.
class Geolocation {
  /// Creates a [Geolocation] instance.
  ///
  /// [longitude] is the east-west position on the Earth's surface.
  /// [latitude] is the north-south position on the Earth's surface.
  const Geolocation({
    required this.longitude,
    required this.latitude,
  });

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
}
