import 'dart:ui';

extension AzureColorExtension on Color {
  String toAzureMapsFormat() {
    return '${(r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
        '${(g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
        '${(b * 255).toInt().toRadixString(16).padLeft(2, '0')}';
  }
}
