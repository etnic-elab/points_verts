import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/services.dart';
import 'package:points_verts/services/assets.dart';

class MarkerGenerator {
  final num _markerSize;
  late double _circleOffset;
  late double _fillCircleWidth;
  late double _iconSize;

  MarkerGenerator(this._markerSize) {
    final circleStrokeWidth = _markerSize / 100.0;
    _circleOffset = _markerSize / 2;
    _fillCircleWidth = _markerSize / 2.35;
    final outlineCircleInnerWidth = _markerSize - (2 * circleStrokeWidth);
    _iconSize = sqrt(pow(outlineCircleInnerWidth, 2) / 2);
  }

  /// Creates a BitmapDescriptor from an IconData
  Future<BitmapDescriptor> fromByteData(
    ByteData assetData,
    Color circleColor,
    Color backgroundColor,
  ) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final assetImage = await Assets.asset.sizedBytes(
      assetData,
      _iconSize.round(),
    );

    _paintCircleFill(canvas, backgroundColor);
    _paintImage(canvas, assetImage);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      _markerSize.round(),
      _markerSize.round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Creates a BitmapDescriptor from an IconData
  Future<BitmapDescriptor> fromIconData(
    IconData iconData,
    Color iconColor,
  ) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    _paintIcon(canvas, iconColor, iconData);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      _markerSize.round(),
      _markerSize.round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Paints the icon background
  void _paintCircleFill(Canvas canvas, Color color) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color;
    canvas.drawCircle(
      Offset(_circleOffset, _circleOffset),
      _fillCircleWidth,
      paint,
    );
  }

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
      ),
    );
    textPainter.layout();

    final dx = _circleOffset - textPainter.width / 2;
    final dy = _circleOffset - textPainter.height / 2;
    textPainter.paint(canvas, Offset(dx, dy));
  }

  void _paintImage(Canvas canvas, ui.Image image) {
    final paint = Paint();
    final dx = _circleOffset - image.width / 2;
    final dy = _circleOffset - image.height / 2;
    canvas.drawImage(image, Offset(dx, dy), paint);
  }
}
