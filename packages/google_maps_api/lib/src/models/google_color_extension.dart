import 'dart:ui';

extension GoogleColorExtension on Color {
  String toGoogleMapsFormat({bool withAlpha = false}) {
    if (withAlpha) {
      return '0x${red.toRadixString(16).padLeft(2, '0')}'
          '${green.toRadixString(16).padLeft(2, '0')}'
          '${blue.toRadixString(16).padLeft(2, '0')}'
          '${alpha.toRadixString(16).padLeft(2, '0')}';
    } else {
      return '0x${red.toRadixString(16).padLeft(2, '0')}'
          '${green.toRadixString(16).padLeft(2, '0')}'
          '${blue.toRadixString(16).padLeft(2, '0')}';
    }
  }
}
