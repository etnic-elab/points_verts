import 'dart:math';
import 'package:address_repository/address_repository.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maps_api/maps_api.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/locator.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walk_details_info.dart';

// Constants
const double minMapHeight = 200.0;
const double portraitMapHeightRatioWithPaths = 0.35;
const double portraitMapHeightRatioWithoutPaths = 0.25;

class WalkDetailsInfoView extends StatelessWidget {
  const WalkDetailsInfoView(
    this.walk,
    this.onTapMap,
    this.pathsLoaded, {
    super.key,
  });

  final Walk walk;
  final Function onTapMap;
  final bool pathsLoaded;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) => _buildLayout(context, orientation),
    );
  }

  Widget _buildLayout(BuildContext context, Orientation orientation) {
    final isLandscape = orientation == Orientation.landscape;
    final children = [
      _buildMapContainer(context, isLandscape: isLandscape),
      WalkDetailsInfo(walk),
    ];

    return isLandscape
        ? Row(mainAxisSize: MainAxisSize.max, children: children)
        : Column(mainAxisSize: MainAxisSize.max, children: children);
  }

  Widget _buildMapContainer(BuildContext context, {required bool isLandscape}) {
    final size = MediaQuery.of(context).size;
    final mapSize = MapUtils.calculateMapSize(size, isLandscape, walk.hasPaths);

    return SizedBox(
      width: mapSize.width,
      height: mapSize.height,
      child:
          !pathsLoaded ? const Loading() : _buildMap(context, mapSize: mapSize),
    );
  }

  Widget _buildMap(
    BuildContext context, {
    required Size mapSize,
  }) {
    final url = MapUtils.getStaticMapUrl(context, walk, mapSize);
    return _buildStaticImage(url: url, onTap: onTapMap);
  }

  Widget _buildStaticImage({required String url, Function? onTap}) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: url,
      imageBuilder: onTap == null
          ? null
          : (context, imageProvider) =>
              _buildTappableImage(imageProvider, onTap),
      progressIndicatorBuilder: (context, url, progress) =>
          Center(child: CircularProgressIndicator(value: progress.progress)),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  Widget _buildTappableImage(ImageProvider imageProvider, Function onTap) {
    return Semantics(
      excludeSemantics: true,
      label: "Voir les parcours sur une carte",
      button: true,
      child: Ink.image(
        image: imageProvider,
        fit: BoxFit.cover,
        child: Stack(
          children: [
            const Positioned(
              bottom: 15.0,
              right: 10.0,
              child: FloatingActionButton.small(
                onPressed: null,
                child: Icon(Icons.open_in_full),
              ),
            ),
            InkWell(onTap: () => onTap())
          ],
        ),
      ),
    );
  }
}

class MapUtils {
  static Size calculateMapSize(
      Size screenSize, bool isLandscape, bool hasPaths) {
    if (isLandscape) {
      return Size(screenSize.width / 2, screenSize.height);
    }
    final heightRatio = hasPaths
        ? portraitMapHeightRatioWithPaths
        : portraitMapHeightRatioWithoutPaths;
    return Size(
      screenSize.width,
      max(minMapHeight, screenSize.height * heightRatio),
    );
  }

  static String getStaticMapUrl(BuildContext context, Walk walk, Size mapSize) {
    final addressRepository = locator<AddressRepository>();
    final brightness = Theme.of(context).brightness;

    return addressRepository.getStaticMapUrl(
      width: mapSize.width.round(),
      height: mapSize.height.round(),
      markers: [
        MapMarker(
          geolocation: Geolocation(
            longitude: walk.long ?? 0,
            latitude: walk.lat ?? 0,
          ),
          iconUrl: _getIconUrl(walk, brightness),
        )
      ],
      paths: walk.paths
          .where((path) => path.encodablePoints.isNotEmpty)
          .map((path) => MapPath(
                points: path.encodablePoints,
                color: path.getColor(brightness),
              ))
          .toList(),
      brightness: brightness,
    );
  }

  static String _getIconUrl(Walk walk, Brightness brightness) {
    if (walk.isCancelled) {
      return (brightness == Brightness.dark)
          ? publicLogoCancelledDark
          : publicLogoCancelledLight;
    }
    return publicLogo;
  }
}
