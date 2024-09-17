import 'dart:ui';

extension AzureColorExtension on Color {
  String toAzureMapsFormat() {
    return '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }
}
