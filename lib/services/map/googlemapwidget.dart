import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/walks/walk_tile.dart';

// The zoom level of the camera
const double CAMERA_ZOOM = 7.5;
//The angle, in degrees, of the camera angle from the nadir.
const double CAMERA_TILT = 0;
// The camera's bearing in degrees, measured clockwise from north
const double CAMERA_BEARING = 0;

// those two constants define the positions that allows the code to hide/show the Walk Tile when (un)selected
const double PIN_VISIBLE_POSITION = 20;
const double PIN_INVISIBLE_POSITION = -220;

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget(
      {Key? key,
      required this.rawMarkers,
      this.centerLat = 50.3155646,
      this.centerLong = 5.009682,
      this.zoom = CAMERA_ZOOM,
      this.tilt = CAMERA_TILT,
      this.bearing = CAMERA_BEARING,
      this.brightness = Brightness.light,
      this.child})
      : super(key: key);

  final double centerLat;
  final double centerLong;
  final double zoom;
  final double tilt;
  final double bearing;
  final List<Map> rawMarkers;
  final Brightness brightness;
  final Widget? child;

  @override
  State<GoogleMapWidget> createState() => GoogleMapWidgetState();
}

class GoogleMapWidgetState extends State<GoogleMapWidget> {
  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor walkIcon =
      BitmapDescriptor.defaultMarker; //used to display a walk
  BitmapDescriptor walkCanceledIcon =
      BitmapDescriptor.defaultMarker; //used to display a cancelled walk
  BitmapDescriptor homeIcon =
      BitmapDescriptor.defaultMarker; //used to display the home position
  double pinPillPosition =
      PIN_INVISIBLE_POSITION; //define the pin / walk tile position to invisible by default
  StatelessWidget walkTile = Text(
      "Temp"); //used to show the walk tile; by default set a useless StatelessWidget that will be overridden when a walk is selected

  @override
  void initState() {
    super.initState();
    // start the generation of the walk icons from the assets
    this.setWalkIcons();
  }

  //returns the path to an asset
  String getAssetPath(String fileName) {
    String brightness =
        widget.brightness == Brightness.light ? "light" : "dark";
    String assetPath = 'assets/$brightness/$fileName.png';
    return assetPath;
  }

  // generate the walk icons from the assets
  void setWalkIcons() async {
    walkIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), getAssetPath('logo90'));

    walkCanceledIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), getAssetPath("logo-annule90"));
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Marker> _markers = {};

    //start the creation of the markers
    widget.rawMarkers.forEach((element) {
      //create a new marker
      final marker;
      // if this is a walk, create a walk marker
      if (element.containsKey("walk")) {
        //the default icon is the walkIcon
        BitmapDescriptor markerIcon = walkIcon;
        Walk elementWalk = element['walk'];
        if (elementWalk.isCancelled()) {
          markerIcon = walkCanceledIcon;
        }
        marker = Marker(
            markerId: MarkerId(
                elementWalk.lat.toString() + elementWalk.long!.toString()),
            position: LatLng(elementWalk.lat!, elementWalk.long!),
            infoWindow: InfoWindow(),
            icon: markerIcon,
            consumeTapEvents: true,
            onTap: () {
              //define the behaviour when the marker is selected
              setState(() {
                walkTile = WalkTile(element['walk'],
                    TileType.calendar); //define the content of the Walk Tile
                this.pinPillPosition =
                    PIN_VISIBLE_POSITION; //set the Walk Tile as visible
              });
            });
        //store all markers in a structure that we will use later for the maps
        _markers[elementWalk.lat.toString() + elementWalk.long!.toString()] =
            marker;
      } else {
        // otherwise create the home/default marker
        marker = Marker(
            markerId: MarkerId(element['latitude'].toString() +
                element['longitude'].toString()),
            position: LatLng(element['latitude'], element['longitude']),
            infoWindow: InfoWindow(
                title: "Domicile",
                snippet: "Vous pouvez le modifier via les paramètres"),
            icon: homeIcon);
        //store the home marker in the markers that we will use later for the maps
        _markers[element['latitude'].toString() +
            element['longitude'].toString()] = marker;
      }
    });

    // generate a structure that contains the GoogleMap and the animated WalkTile
    return new Scaffold(
        body: Stack(children: [
      Positioned.fill(
          child: GoogleMap(
              mapType:
                  MapType.normal, // none, normal, hybrid, satellite and terrain
              initialCameraPosition: CameraPosition(
                  target: LatLng(widget.centerLat, widget.centerLong),
                  zoom: widget.zoom,
                  tilt: widget.tilt,
                  bearing: widget.bearing),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (LatLng loc) {
                setState(() {
                  this.pinPillPosition = PIN_INVISIBLE_POSITION;
                });
              },
              markers: _markers.values.toSet())),
      AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          left: 0,
          right: 0,
          bottom: this.pinPillPosition,
          child: walkTile)
    ]));
  }
}
