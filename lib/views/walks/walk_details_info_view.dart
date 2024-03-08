import 'dart:math';

import 'package:flutter/material.dart';
import 'package:points_verts/constants.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walk_details_info.dart';
import 'package:collection/collection.dart';
import 'package:points_verts/services/map/map_interface.dart';

class WalkDetailsInfoView extends StatelessWidget {
  const WalkDetailsInfoView(this.walk, this.onTapMap, this.pathsLoaded,
      {super.key});

  final Walk walk;
  final Function onTapMap;
  final bool pathsLoaded;

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
    bool hasPaths =
        walk.paths.firstWhereOrNull((path) => path.gpxPoints.isNotEmpty) !=
            null;
    Brightness brightness = Theme.of(context).brightness;
    Size size = MediaQuery.of(context).size;
    double height = landscape
        ? size.height
        : hasPaths
            ? max(200, size.height * 0.35)
            : max(200, size.height * 0.25);
    double width = landscape ? size.width / 2 : size.width;

    return SizedBox(
      width: width.roundToDouble(),
      height: height.roundToDouble(),
      child: pathsLoaded
          ? kMap.instance.retrieveStaticImage(
              walk, width.round(), height.round(), brightness,
              onTap: hasPaths ? onTapMap : null)
          : const Loading(),
    );
  }
}
