import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:points_verts/company_data.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/map/markers/marker_generator.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/views/loading.dart';
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
      this.markers, this.onMapTap, this.centerLat, this.centerLong, this.zoom,
      {Key? key})
      : super(key: key);

  final List<MarkerInterface> markers;
  final Function onMapTap;
  final double centerLat;
  final double centerLong;
  final double zoom;

  @override
  State<StatefulWidget> createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMap> with WidgetsBindingObserver {
  final Completer<google.GoogleMapController> _controller = Completer();

  Map<Brightness, String>? _mapStyles;
  Map<Brightness, Map<Enum, google.BitmapDescriptor>>? _mapIcons;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _loadMapStyles();
    _loadMapIcons();
  }

  Future<void> _loadMapStyles() async {
    //Load light/dark map styles from assets
    Map<Brightness, String> mapStyles = <Brightness, String>{};
    for (Brightness theme in [Brightness.dark, Brightness.light]) {
      mapStyles[theme] =
          await Assets.instance.assetJson(theme, Assets.googleMap);
    }

    setState(() {
      _mapStyles = mapStyles;
    });
  }

  Future<void> _loadMapIcons() async {
    final Map<Brightness, Map<Enum, google.BitmapDescriptor>> mapIcons =
        <Brightness, Map<Enum, google.BitmapDescriptor>>{};

    //Generate walk icons
    MarkerGenerator markerGenerator = MarkerGenerator(90);
    for (Brightness theme in [Brightness.dark, Brightness.light]) {
      final Map<Enum, google.BitmapDescriptor> icons =
          <Enum, google.BitmapDescriptor>{};

      for (GoogleMapIcons mapEnum in GoogleMapIcons.values) {
        final byteData =
            await Assets.instance.assetByteData(theme, mapEnum.logo);
        final google.BitmapDescriptor image =
            await markerGenerator.createBitmapDescriptorFromByteData(
                byteData, mapEnum.color, mapEnum.color);
        icons[mapEnum] = image;
      }

      //Generate Places icons
      for (Places placeEnum in Places.values) {
        Color color = theme == Brightness.light ? Colors.black : Colors.white;
        final google.BitmapDescriptor image = await markerGenerator
            .createBitmapDescriptorFromIconData(placeEnum.icon, color);
        icons[placeEnum] = image;
      }
      mapIcons[theme] = icons;
    }

    setState(() {
      _mapIcons = mapIcons;
    });
  }

  //Update the mapstyle after a theme (light/dark) change
  Future<void> _setMapStyle() async {
    final controller = await _controller.future;
    final theme = WidgetsBinding.instance!.window.platformBrightness;
    controller.setMapStyle(_mapStyles![theme]);
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

  @override
  Widget build(BuildContext context) {
    google.CameraPosition initialLocation = google.CameraPosition(
        target: google.LatLng(widget.centerLat, widget.centerLong),
        zoom: widget.zoom);

    final Set<google.Marker> _googleMarkers = <google.Marker>{};
    final Brightness theme = Theme.of(context).brightness;

    if (_mapIcons?[theme] != null) {
      for (MarkerInterface marker in widget.markers) {
        _googleMarkers.add(marker.buildGoogleMarker(_mapIcons![theme]!));
      }
    }

    if (_mapStyles != null) {
      return google.GoogleMap(
          mapType: google
              .MapType.normal, // none, normal, hybrid, satellite and terrain
          initialCameraPosition: initialLocation,
          onMapCreated: (google.GoogleMapController controller) {
            controller.setMapStyle(_mapStyles![theme]);
            _controller.complete(controller);
          },
          onTap: (google.LatLng _) {
            widget.onMapTap();
          },
          markers: _googleMarkers);
    } else {
      return const Loading();
    }
  }
}
