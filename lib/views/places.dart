import 'package:flutter/material.dart';

enum Places { home, current }

extension PlacesExtension on Places {
  IconData get icon {
    switch (this) {
      case Places.current:
        return Icons.location_on;
      case Places.home:
        return Icons.home;
    }
  }

  String get text {
    switch (this) {
      case Places.current:
        return "position actuelle";
      case Places.home:
        return "domicile";
    }
  }
}
