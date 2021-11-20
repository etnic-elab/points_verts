import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class Assets {
  Assets._();
  static final Assets instance = Assets._();

  static const String logo = 'logo';
  static const String logoAnnule = 'logo-annule';
  static const String googleMap = 'google_map_style';
  static const String googleMapStatic = 'google_map_style_static';

  String _assetPath(Brightness brightness, String asset, String fileExtension) {
    return 'assets/${brightness.toString().split('.').last}/$asset.$fileExtension';
  }

  AssetImage assetImage(Brightness brightness, String asset) {
    return AssetImage(_assetPath(brightness, asset, 'png'));
  }

  Future<ByteData> assetByteData(Brightness brightness, String asset) async {
    return await rootBundle.load(_assetPath(brightness, asset, 'png'));
  }

  Future<ui.Image> sizedImageBytes(ByteData data, int width) async {
    final ui.Codec codec = await ui
        .instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final bytes = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
    return await decodeImageFromList(bytes);
  }

  Future<String> assetJson(Brightness brightness, String asset) async {
    return await rootBundle.loadString(_assetPath(brightness, asset, 'json'));
  }

  Future<String> assetText(Brightness brightness, String asset) async {
    return await rootBundle.loadString(_assetPath(brightness, asset, 'txt'));
  }
}
