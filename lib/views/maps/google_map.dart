import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:points_verts/models/gpx_point.dart';
import 'package:points_verts/models/path.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/maps/markers/marker_generator.dart';
import 'package:points_verts/views/maps/markers/marker_interface.dart';
import 'package:points_verts/views/walks/walks_view.dart';
import 'package:points_verts/extensions.dart';

enum GoogleMapIcons {
  unselectedWalkIcon,
  unselectedCancelIcon,
  selectedWalkIcon,
  selectedCancelIcon
}

class GoogleMap extends StatefulWidget {
  const GoogleMap({
    super.key,
    required this.initialLocation,
    this.locationEnabled = false,
    this.markers = const <MarkerInterface>[],
    this.paths = const <Path>[],
    this.onTapMap,
  });

  final google.CameraPosition initialLocation;
  final bool locationEnabled;
  final List<MarkerInterface> markers;
  final List<Path> paths;
  final Function? onTapMap;

  @override
  State<StatefulWidget> createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMap> with WidgetsBindingObserver {
  Map<Brightness, String> _mapStyles = {};
  Map<Brightness, Map<Enum, google.BitmapDescriptor>> _mapIcons = {};
  google.MapType _currentMapType = google.MapType.normal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyles();
    _loadDefaultMapType();
    Future.delayed(Duration.zero, () {
      _loadMapIcons();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadMapStyles() async {
    Map<Brightness, String> mapStyles = <Brightness, String>{};
    for (Brightness brightness in [Brightness.dark, Brightness.light]) {
      mapStyles[brightness] =
          await Assets.asset.string(brightness, Assets.googleMapStyle);
    }
    _mapStyles = mapStyles;
  }

  Future<void> _loadDefaultMapType() async {
    final defaultTypeIndex =
        await PrefsProvider.prefs.getInt(Prefs.defaultMapType);
    if (mounted) {
      setState(() {
        _currentMapType = google
            .MapType.values[defaultTypeIndex ?? google.MapType.normal.index];
      });
    }
  }

  Future<void> _loadMapIcons() async {
    if (widget.markers.isNotEmpty) {
      final Map<Brightness, Map<Enum, google.BitmapDescriptor>> mapIcons = {};

      double size = MediaQuery.of(context).devicePixelRatio * 40;
      MarkerGenerator markerGenerator = MarkerGenerator(size);

      for (Brightness brightness in [Brightness.dark, Brightness.light]) {
        final Map<Enum, google.BitmapDescriptor> icons = {};

        for (GoogleMapIcons mapEnum in GoogleMapIcons.values) {
          final byteData =
              await Assets.asset.bytedata(brightness, mapEnum.logo);
          final google.BitmapDescriptor image = await markerGenerator
              .fromByteData(byteData, mapEnum.color, mapEnum.color);
          icons[mapEnum] = image;
        }

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

  Set<google.Polyline> get _polylines {
    final Set<google.Polyline> polylines = {};
    Brightness brightness = Theme.of(context).brightness;

    for (int i = 0; i < widget.paths.length; i++) {
      Path path = widget.paths[i];

      google.Polyline polyline = google.Polyline(
        polylineId: google.PolylineId('polylineId_$i'),
        color: path.getColor(brightness),
        width: 4,
        visible: path.visible,
        points: path.gpxPoints.map((GpxPoint point) => point.latLng).toList(),
      );

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

  void _onMapTypeButtonPressed() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Normal'),
              onTap: () {
                setState(() {
                  _currentMapType = google.MapType.normal;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: const Text('Satellite'),
              onTap: () {
                setState(() {
                  _currentMapType = google.MapType.satellite;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.terrain),
              title: const Text('Relief'),
              onTap: () {
                setState(() {
                  _currentMapType = google.MapType.terrain;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.layers),
              title: const Text('Hybride'),
              onTap: () {
                setState(() {
                  _currentMapType = google.MapType.hybrid;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return Stack(
      children: [
        google.GoogleMap(
          mapType: _currentMapType,
          initialCameraPosition: widget.initialLocation,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          myLocationEnabled: widget.locationEnabled,
          style: _mapStyles[brightness],
          polylines: _polylines,
          onTap: (_) {
            if (widget.onTapMap != null) {
              widget.onTapMap!();
            }
          },
          markers: _markers,
        ),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: "mapType",
            mini: true,
            onPressed: _onMapTypeButtonPressed,
            child: const Icon(Icons.layers),
          ),
        ),
      ],
    );
  }
}
