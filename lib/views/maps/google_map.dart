import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:points_verts/company_data.dart';
import 'package:points_verts/models/path.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/map/markers/marker_generator.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/views/walks/walks_view.dart';

//Enum used for walk icon generation
enum GoogleMapIcons {
  unselectedWalkIcon,
  unselectedCancelIcon,
  selectedWalkIcon,
  selectedCancelIcon
}

extension GoogleMapIconsExtension on GoogleMapIcons {
  String get logo {
    switch (this) {
      case GoogleMapIcons.unselectedWalkIcon:
      case GoogleMapIcons.selectedWalkIcon:
        return Assets.logo;
      case GoogleMapIcons.unselectedCancelIcon:
      case GoogleMapIcons.selectedCancelIcon:
        return Assets.logoAnnule;
    }
  }

  Color get color {
    switch (this) {
      case GoogleMapIcons.unselectedWalkIcon:
      case GoogleMapIcons.unselectedCancelIcon:
        return CompanyColors.darkGreen;
      case GoogleMapIcons.selectedWalkIcon:
      case GoogleMapIcons.selectedCancelIcon:
        return CompanyColors.lightestGreen;
    }
  }
}

class GoogleMap extends StatefulWidget {
  const GoogleMap(
      {Key? key,
      required this.initialLocation,
      this.locationEnabled = false,
      this.markers = const <MarkerInterface>[],
      this.paths = const <Path>[],
      this.onTapMap,
      this.onTapPath})
      : super(key: key);

  final google.CameraPosition initialLocation;
  final bool locationEnabled;
  final List<MarkerInterface> markers;
  final List<Path> paths;
  final Function? onTapMap;
  final Function(Path)? onTapPath;

  @override
  State<StatefulWidget> createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMap> with WidgetsBindingObserver {
  final Completer<google.GoogleMapController> _completer = Completer();
  Map<Brightness, String> _mapStyles = {};
  Map<Brightness, Map<Enum, google.BitmapDescriptor>> _mapIcons = {};
  int? _selectedPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _loadMapStyles();
    Future.delayed(Duration.zero, () {
      _loadMapIcons();
    });
  }

  @override
  void didChangePlatformBrightness() {
    _setMapStyle();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadMapStyles() async {
    //Load light/dark map styles from assets
    Map<Brightness, String> mapStyles = <Brightness, String>{};
    for (Brightness brightness in [Brightness.dark, Brightness.light]) {
      mapStyles[brightness] =
          await Assets.asset.string(brightness, Assets.googleMapStyle);
    }
    _mapStyles = mapStyles;
  }

  Future<void> _loadMapIcons() async {
    if (widget.markers.isNotEmpty) {
      final Map<Brightness, Map<Enum, google.BitmapDescriptor>> mapIcons = {};

      double size = MediaQuery.of(context).devicePixelRatio * 40;
      MarkerGenerator markerGenerator = MarkerGenerator(size);

      //Generate walk icons
      for (Brightness brightness in [Brightness.dark, Brightness.light]) {
        final Map<Enum, google.BitmapDescriptor> icons = {};

        for (GoogleMapIcons mapEnum in GoogleMapIcons.values) {
          final byteData =
              await Assets.asset.bytedata(brightness, mapEnum.logo);
          final google.BitmapDescriptor image = await markerGenerator
              .fromByteData(byteData, mapEnum.color, mapEnum.color);
          icons[mapEnum] = image;
        }

        //Generate Places icons
        for (Places placeEnum in Places.values) {
          Color color =
              brightness == Brightness.light ? Colors.black : Colors.white;
          final google.BitmapDescriptor image =
              await markerGenerator.fromIconData(placeEnum.icon, color);
          icons[placeEnum] = image;
        }
        mapIcons[brightness] = icons;
      }

      if (mounted) {
        setState(() {
          _mapIcons = mapIcons;
        });
      }
    }
  }

  //Update the mapstyle after a theme (light/dark) change
  Future<void> _setMapStyle() async {
    final controller = await _completer.future;
    final theme = WidgetsBinding.instance!.window.platformBrightness;
    controller.setMapStyle(_mapStyles[theme]);
  }

  Set<google.Polyline> get _polylines {
    final Set<google.Polyline> polylines = {};
    Brightness brightness = Theme.of(context).brightness;

    for (int i = 0; i < widget.paths.length; i++) {
      Path _path = widget.paths[i];

      google.Polyline polyline = google.Polyline(
          polylineId: google.PolylineId('polylineId_$i'),
          color: Path.color(brightness, i),
          width: 4,
          visible: _selectedPath == null || _selectedPath == i,
          points: _path.latLngList,
          consumeTapEvents: widget.onTapPath != null,
          onTap: () {
            if (widget.onTapPath != null) {
              widget.onTapPath!(_path);
              setState(() {
                _selectedPath = i;
              });
            }
          });

      polylines.add(polyline);
    }

    return polylines;
  }

  Set<google.Marker> get _markers {
    final mapIcons = _mapIcons[Theme.of(context).brightness];
    if (mapIcons == null) return {};
    return widget.markers
        .map<google.Marker>(
            (MarkerInterface marker) => marker.buildGoogleMarker(mapIcons))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return google.GoogleMap(
        mapType: google
            .MapType.normal, // none, normal, hybrid, satellite and terrain
        initialCameraPosition: widget.initialLocation,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        myLocationEnabled: widget.locationEnabled,
        onMapCreated: (google.GoogleMapController controller) {
          controller.setMapStyle(_mapStyles[brightness]);
          _completer.complete(controller);
        },
        polylines: _polylines,
        onTap: (_) {
          if (widget.onTapMap != null) {
            widget.onTapMap!();
            setState(() {
              _selectedPath = null;
            });
          }
        },
        markers: _markers);
  }
}
