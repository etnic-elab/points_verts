import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maps_api/maps_api.dart';
import 'package:maps_repository/maps_repository.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/locator.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walk_details_info.dart';

// Constants
const double minMapHeight = 200.0;
const double portraitMapHeightRatio = 0.35;

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
    final mapSize = MapUtils.calculateMapSize(size, isLandscape);

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

  Widget _buildStaticImage({required String url, required Function onTap}) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: url,
      imageBuilder: (context, imageProvider) =>
          _buildTappableImage(context, imageProvider, onTap),
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(value: progress.progress),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  Widget _buildTappableImage(
      BuildContext context, ImageProvider imageProvider, Function onTap) {
    return Semantics(
      excludeSemantics: true,
      label: "Ouvrir la carte interactive",
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
                child: Icon(Icons.zoom_out_map),
              ),
            ),
            if (walk.hasPaths)
              Positioned(
                top: 10.0,
                right: 10.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: CompanyColors.orange.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Parcours disponibles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: const Offset(1.0, 1.0),
                          blurRadius: 2.0,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
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
  static Size calculateMapSize(Size screenSize, bool isLandscape) {
    if (isLandscape) {
      return Size(screenSize.width / 2, screenSize.height);
    }
    return Size(
      screenSize.width,
      max(minMapHeight, screenSize.height * portraitMapHeightRatio),
    );
  }

  static String getStaticMapUrl(BuildContext context, Walk walk, Size mapSize) {
    final mapsRepository = locator<MapsRepository>();
    final brightness = Theme.of(context).brightness;

    return mapsRepository.getStaticMapUrl(
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
