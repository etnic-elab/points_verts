import 'package:flutter/material.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walk_details_info.dart';
import 'package:collection/collection.dart';

class WalkDetailsInfoView extends StatelessWidget {
  WalkDetailsInfoView(this.walk, this.onTapMap, this.pathsLoaded, {Key? key})
      : super(key: key);

  final Walk walk;
  final Function onTapMap;
  final bool pathsLoaded;
  final MapInterface map = Environment.mapInterface;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
            _buildMap(context, false),
            WalkDetailsInfo(walk)
          ]);
        } else {
          return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
            _buildMap(context, true),
            WalkDetailsInfo(walk)
          ]);
        }
      },
    );
  }

  Widget _buildMap(BuildContext context, bool landscape) {
    Brightness brightness = Theme.of(context).brightness;
    Size size = MediaQuery.of(context).size;
    double height =
        landscape ? size.height : MediaQuery.of(context).size.height * 0.35;
    double width = landscape ? size.width / 2 : size.width;

    return SizedBox(
      width: width.roundToDouble(),
      height: height.roundToDouble(),
      child: pathsLoaded
          ? map.retrieveStaticImage(
              walk, width.round(), height.round(), brightness,
              onTap: walk.paths.firstWhereOrNull(
                          (_path) => _path.gpxPoints.isNotEmpty) !=
                      null
                  ? onTapMap
                  : null)
          : const Loading(),
    );
  }
}
