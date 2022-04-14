class SortBy {
  SortBy.defaultValue()
      : type = SortType.city,
        direction = SortDirection.asc;
  SortBy.alphabetical(this.direction, [this.type = SortType.city]);
  SortBy.position(this.type, [this.direction = SortDirection.asc]);

  final SortType type;
  final SortDirection direction;

  SortBy.fromJson(Map<String, dynamic> json)
      : type = SortType.values.singleWhere((type) => type.name == json['type']),
        direction = SortDirection.values
            .singleWhere((direction) => direction.name == json['direction']);

  Map<String, dynamic> toJson() =>
      {'type': type.name, 'direction': direction.name};

  bool get position =>
      [SortType.homePosition, SortType.currentPosition].contains(type);

  @override
  bool operator ==(Object other) =>
      other is SortBy &&
      other.runtimeType == runtimeType &&
      other.type == type &&
      other.direction == direction;

  @override
  int get hashCode => type.hashCode + direction.hashCode;
}

enum SortType { city, province, homePosition, currentPosition }
enum SortDirection { asc, desc }

extension SortTypeExt on SortType {
  String get name {
    switch (this) {
      case SortType.city:
        return 'city';
      case SortType.province:
        return 'province';
      case SortType.homePosition:
        return 'homePosition';
      case SortType.currentPosition:
        return 'currentPosition';
    }
  }
}

extension SortDirectionExt on SortDirection {
  String get name {
    switch (this) {
      case SortDirection.asc:
        return 'ASC';
      case SortDirection.desc:
        return 'DESC';
    }
  }
}
