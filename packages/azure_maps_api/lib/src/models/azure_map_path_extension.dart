import 'package:azure_maps_api/src/models/azure_color_extension.dart';
import 'package:maps_api/maps_api.dart';

extension AzureMapPathExtension on MapPath {
  String toAzureEncode() {
    final style = 'lc${color.toAzureMapsFormat()}|lw${weight ?? 5}';
    final pointsString = points.map((p) => '${p[1]} ${p[0]}').join('|');

    return '$style||$pointsString';
  }
}
