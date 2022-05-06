class PositionNotFoundException implements Exception {
  String message;
  Object? error;
  PositionNotFoundException(this.message, {this.error});
}

class DatesNotFoundException implements Exception {
  String cause;
  DatesNotFoundException(this.cause);
}
