import 'dart:ui';

extension MapboxColorExtension on Color {
  String toMapboxFormat() {
    return '#${(r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
        '${(g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
        '${(b * 255).toInt().toRadixString(16).padLeft(2, '0')}';
  }
}
