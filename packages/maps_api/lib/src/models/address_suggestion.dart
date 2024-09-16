import 'package:maps_api/maps_api.dart';
import 'package:maps_api/src/models/geolocation.dart';

/// Represents a suggested address with identifiers and optional coordinates.
class AddressSuggestion {
  /// Creates an [AddressSuggestion] instance.
  ///
  /// [mainText] is the human-readable address.
  /// [description] is a detailed description of the suggested place.
  /// [placeId] is a unique identifier for the place.
  /// [geolocation] is the optional geographical location
  /// of the suggested place.
  ///
  /// Throws an [ArgumentError] if both [placeId] and [geolocation] are null.
  AddressSuggestion({
    required this.mainText,
    required this.description,
    this.placeId,
    this.geolocation,
  }) {
    if (placeId == null && geolocation == null) {
      throw ArgumentError(
        'At least one of placeId or geolocation must be non-null',
      );
    }
  }

  /// The human-readable formatted address text.
  final String mainText;

  /// A detailed description of the suggested place.
  final String description;

  /// A unique identifier for the place.
  final String? placeId;

  /// The optional geographical location of the suggested place.
  final Geolocation? geolocation;
}
