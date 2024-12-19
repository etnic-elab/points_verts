import 'dart:ui';

extension GoogleColorExtension on Color {
  String toGoogleMapsFormat({bool withAlpha = false}) {
    if (withAlpha) {
      return '0x${(r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
          '${(g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
          '${(b * 255).toInt().toRadixString(16).padLeft(2, '0')}'
          '${(a * 255).toInt().toRadixString(16).padLeft(2, '0')}';
    } else {
      return '0x${(r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
          '${(g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
          '${(b * 255).toInt().toRadixString(16).padLeft(2, '0')}';
    }
  }
}
