import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/models/path.dart';
import 'package:points_verts/models/gpx_point.dart';
import 'package:points_verts/services/gpx.dart';
import 'package:points_verts/services/positioning.dart';
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
  final scaffoldState = GlobalKey<ScaffoldState>();
  _ViewType _viewType = _ViewType.detail;
  bool _sheetOpen = false;
  PersistentBottomSheetController? _sheetController;
  Future<List>? _paths;
  Future<LocationPermission>? _locationPermission;

  @override
  void initState() {
    super.initState();
    _paths = _retrievePaths();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List> _retrievePaths() {
    List<Future> paths = [];
    if (!widget.walk.isCancelled) {
      for (Path path in widget.walk.paths) {
        if ((path.url?.isNotEmpty ?? false) && path.gpxPoints.isEmpty) {
          Future<List<GpxPoint>> future = retrieveGpxPoints(path.url!);
          future.then((List<GpxPoint> _gpxPoints) {
            path.gpxPoints = _gpxPoints;
            path.visible = _gpxPoints.isNotEmpty;
          });
          paths.add(future);
        }
      }
    }
    return Future.wait(paths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        leading: _viewType == _ViewType.detail
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _toggleView(_ViewType.detail),
              ),
        title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.walk.city),
                Text('${widget.walk.type} - ${widget.walk.province}',
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: Theme.of(context).textTheme.caption!.color)),
              ],
            )),
      ),
      body: FutureBuilder(
        future: _paths,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          return _viewType == _ViewType.detail
              ? WalkDetailsInfoView(widget.walk, () {
                  _toggleView(_ViewType.map);
                }, snapshot.hasData)
              : WalkDetailsMapView(widget.walk, closeSheet, location);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _viewType == _ViewType.map
          ? FloatingActionButton(
              child:
                  Icon(_sheetOpen ? Icons.expand_less : Icons.layers_outlined),
              onPressed: _onTapFAB,
            )
          : null,
    );
  }

  void _toggleView(_ViewType type) {
    setState(() => _viewType = type);
    closeSheet();
  }

  void _onTapFAB() {
    if (_sheetOpen) closeSheet();
    if (!_sheetOpen) _openSheet();
  }

  void _openSheet() {
    _sheetController = scaffoldState.currentState?.showBottomSheet(
      (context) => _BottomSheet(widget.walk, togglePathVisibility),
      elevation: 16,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    );

    if (_sheetController != null) setState(() => _sheetOpen = true);
  }

  Future<void> closeSheet() async {
    _sheetController?.close();
    _sheetController?.closed.then((_) => setState(() => _sheetOpen = false));
  }

  void togglePathVisibility(Path path, bool newValue) {
    setState(() {
      path.visible = newValue;
    });
  }

  Future<LocationPermission> location() {
    return _locationPermission ??= checkPermission();
  }
}

class _BottomSheet extends StatefulWidget {
  const _BottomSheet(this.walk, this.togglePathVisibility, {Key? key})
      : super(key: key);
  final Walk walk;
  final Function(Path, bool) togglePathVisibility;

  @override
  State<_BottomSheet> createState() => __BottomSheet();
}

class __BottomSheet extends State<_BottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: _children,
        shrinkWrap: true,
      ),
    );
  }

  List<Widget> get _children {
    Brightness brightness = Theme.of(context).brightness;
    Widget header = const ListTile(
      leading: Icon(Icons.route),
      title: Text('Les parcours'),
    );
    List<Widget> _paths = widget.walk.paths.reversed
        .map((path) => path.gpxPoints.isNotEmpty
            ? SwitchListTile(
                title: Text(
                  path.title,
                ),
                subtitle:
                    path.description != null ? Text(path.description!) : null,
                value: path.visible,
                onChanged: (bool newValue) {
                  widget.togglePathVisibility(path, newValue);
                  setState(() => path.visible = newValue);
                },
                secondary: Icon(Icons.circle, color: path.getColor(brightness)),
              )
            : null)
        .whereType<Widget>()
        .toList();

    return [header, const Divider(), ..._paths];
  }
}
