import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/models/path.dart';
import 'package:points_verts/models/path_point.dart';
import 'package:points_verts/services/gpx.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/views/walks/walk_details_info_view.dart';
import 'package:points_verts/views/walks/walk_details_map_view.dart';

import '../../models/walk.dart';

enum _ViewType { detail, map }

class WalkDetailsView extends StatefulWidget {
  const WalkDetailsView(this.walk, {Key? key}) : super(key: key);

  final Walk walk;

  @override
  State<WalkDetailsView> createState() => _WalkDetailsViewState();
}

class _WalkDetailsViewState extends State<WalkDetailsView> {
  final MapInterface map = Environment.mapInterface;
  _ViewType viewType = _ViewType.detail;
  Path? selectedPath;

  Future<List> _retrievePaths() {
    List<Future<List<PathPoint>>> paths = [];
    if (!widget.walk.isCancelled && !widget.walk.hasPath) {
      for (Path path in widget.walk.paths) {
        if (path.url?.isNotEmpty ?? false) {
          Future<List<PathPoint>> future = retrievePathPoints(path.url!);
          future.then((_pathPoints) {
            path.pathPoints = _pathPoints;
          });
          paths.add(future);
        }
      }
    }
    return Future.wait(paths);
  }

  @override
  Widget build(BuildContext context) {
    DateFormat fullDate = DateFormat.yMMMMEEEEd("fr_BE");
    return Scaffold(
      appBar: AppBar(
        leading: viewType == _ViewType.detail
            ? IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back))
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _toggleView(_ViewType.detail);
                },
              ),
        title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.walk.city),
                Text(
                    "${widget.walk.type} du ${fullDate.format(widget.walk.date)}",
                    style: const TextStyle(fontSize: 14)),
              ],
            )),
      ),
      body: FutureBuilder(
        future: _retrievePaths(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          return viewType == _ViewType.detail
              ? WalkDetailsInfoView(widget.walk, () {
                  _toggleView(_ViewType.map);
                })
              : WalkDetailsMapView(
                  widget.walk, selectedPath, onTapMap, onTapPath);
        },
      ),
    );
  }

  void _toggleView(_ViewType type) {
    setState(() {
      viewType = type;
    });
  }

  void onTapMap() {
    setState(() {
      selectedPath = null;
    });
  }

  void onTapPath(Path path) {
    setState(() {
      selectedPath = path;
    });
  }
}
