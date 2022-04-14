class PositionNotFoundException implements Exception {
  String cause;
  PositionNotFoundException(this.cause);
}

class DatesNotFoundException implements Exception {
  String cause;
  DatesNotFoundException(this.cause);
}
