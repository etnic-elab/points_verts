class Address {
  Address({
    required this.address,
    required this.longitude,
    required this.latitude,
  });

  final String address;
  final double longitude;
  final double latitude;
}

class AddressSuggestion {
  final String placeId;
  final String name;
  final String description;

  AddressSuggestion(this.placeId, this.name, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, name: $name, placeId: $placeId)';
  }
}
