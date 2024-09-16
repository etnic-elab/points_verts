import 'dart:ui';

extension ColorExtension on Color {
  String toHexString({bool withAlpha = false}) {
    var hex = '#';
    if (withAlpha) {
      hex += alpha.toRadixString(16).padLeft(2, '0');
    }
    hex += red.toRadixString(16).padLeft(2, '0') +
        green.toRadixString(16).padLeft(2, '0') +
        blue.toRadixString(16).padLeft(2, '0');
    return hex.toUpperCase();
  }
}
