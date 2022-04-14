import 'package:flutter/material.dart';

extension ColorExt on Color {
  toHex({bool transparancy = false}) {
    return '0x'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}'
        '${transparancy ? alpha.toRadixString(16).padLeft(2, '0') : ''}';
  }
}
