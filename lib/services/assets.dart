import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class Assets {
  Assets._();
  static final Assets asset = Assets._();

  static const String logo = 'logo.png';
  static const String logoAnnule = 'logo-annule.png';
  static const String googleMapStyle = 'google_map_style.json';
  static const String googleMapStaticStyle = 'google_map_style_static.txt';
  static const String letsEncryptCert = 'assets/raw/isrgrootx1.pem';

  String _path(Brightness brightness, String asset) {
    return 'assets/${brightness.toString().split('.').last}/$asset';
  }

  Future<ByteData> load(String path) async {
    return await rootBundle.load(path);
  }

  Future<ByteData> bytedata(Brightness brightness, String asset) async {
    return await load(_path(brightness, asset));
  }

  Future<ui.Image> sizedBytes(ByteData data, int width) async {
    final ui.Codec codec = await ui
        .instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final bytes = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
    return await decodeImageFromList(bytes);
  }

  Future<String> string(Brightness brightness, String asset) async {
    return await rootBundle.loadString(_path(brightness, asset));
  }

  AssetImage image(Brightness brightness, String asset) {
    return AssetImage(_path(brightness, asset));
  }
}
