import 'dart:math';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/services.dart';
import 'package:points_verts/services/assets.dart';

class MarkerGenerator {
  final num _markerSize;
  late double _circleStrokeWidth;
  late double _circleOffset;
  // late double _outlineCircleWidth;
  late double _fillCircleWidth;
  late double _iconSize;
  late double _iconOffset;

  MarkerGenerator(this._markerSize) {
    // calculate marker dimensions
    _circleStrokeWidth = _markerSize / 100.0;
    _circleOffset = _markerSize / 2;
    // _outlineCircleWidth = _circleOffset - (_circleStrokeWidth / 2);
    _fillCircleWidth = _markerSize / 2.35;
    final outlineCircleInnerWidth = _markerSize - (2 * _circleStrokeWidth);
    _iconSize = sqrt(pow(outlineCircleInnerWidth, 2) / 2);
    final rectDiagonal = sqrt(2 * pow(_markerSize, 2));
    final circleDistanceToCorners =
        (rectDiagonal - outlineCircleInnerWidth) / 2;
    _iconOffset = sqrt(pow(circleDistanceToCorners, 2) / 2);
  }

  /// Creates a BitmapDescriptor from an IconData
  Future<BitmapDescriptor> fromByteData(
      ByteData assetData, Color circleColor, Color backgroundColor) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final assetImage =
        await Assets.asset.sizedBytes(assetData, _iconSize.round());

    _paintCircleFill(canvas, backgroundColor);
    // _paintCircleStroke(canvas, circleColor);
    _paintImage(canvas, assetImage);

    final picture = pictureRecorder.endRecording();
    final image =
        await picture.toImage(_markerSize.round(), _markerSize.round());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  /// Creates a BitmapDescriptor from an IconData
  Future<BitmapDescriptor> fromIconData(
      IconData iconData, Color iconColor) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    _paintIcon(canvas, iconColor, iconData);

    final picture = pictureRecorder.endRecording();
    final image =
        await picture.toImage(_markerSize.round(), _markerSize.round());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  /// Paints the icon background
  void _paintCircleFill(Canvas canvas, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawCircle(
        Offset(_circleOffset, _circleOffset), _fillCircleWidth, paint);
  }

  /// Paints a circle around the icon

  // void _paintCircleStroke(Canvas canvas, Color color) {
  //   final paint = Paint()
  //     ..style = PaintingStyle.stroke
  //     ..color = color
  //     ..strokeWidth = _circleStrokeWidth;
  //   canvas.drawCircle(
  //       Offset(_circleOffset, _circleOffset), _outlineCircleWidth, paint);
  // }

  /// Paints the icon
  void _paintIcon(Canvas canvas, Color color, IconData iconData) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: _iconSize,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: color,
        ));
    textPainter.layout();
    textPainter.paint(canvas, Offset(_iconOffset, _iconOffset));
  }

  void _paintImage(Canvas canvas, ui.Image image) {
    final paint = Paint();
    canvas.drawImage(image, Offset(_iconOffset, _iconOffset), paint);
  }
}
