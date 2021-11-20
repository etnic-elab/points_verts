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
  static const String googlemapDarkJsonPath =
      'assets/dark/google_map_style.json';

  String _assetImagePath(String asset, Brightness brightness) {
    return 'assets/${brightness.toString().split('.').last}/$asset.png';
  }

  AssetImage assetImage(String asset, Brightness brightness) {
    return AssetImage(_assetImagePath(asset, brightness));
  }

  Future<ByteData> assetByteData(String asset, Brightness brightness) async {
    return await rootBundle.load(_assetImagePath(asset, brightness));
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

  Future<String> assetJson(String path) async {
    return await rootBundle.loadString(path);
  }
}
