import 'dart:ui';

import 'package:maps_api/maps_api.dart';

extension AzureMapTypeExtension on MapType {
  String toAzureTilesetId(Brightness brightness) {
    switch (this) {
      case MapType.road:
        return brightness == Brightness.light
            ? 'microsoft.base.road'
            : 'microsoft.base.darkgrey';
      case MapType.satellite:
        return 'microsoft.imagery';
      case MapType.terrain:
        return brightness == Brightness.light
            ? 'microsoft.terra.main'
            : 'microsoft.terra.dark';
      case MapType.hybrid:
        return brightness == Brightness.light
            ? 'microsoft.base.hybrid.road'
            : 'microsoft.base.hybrid.darkgrey';
    }
  }
}
