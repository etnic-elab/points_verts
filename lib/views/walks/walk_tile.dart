import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../tile_icon.dart';
import '../../models/walk.dart';
import 'geo_button.dart';
import 'walk_details_view.dart';
import 'walk_icon.dart';
import '../../models/weather.dart';
import '../../services/openweather.dart';

bool smallScreen = window.physicalSize.width <= 640;
DateFormat fullDate = DateFormat("dd/MM", "fr_BE");

enum TileType { calendar, directory }

class WalkTile extends StatelessWidget {
  const WalkTile(this.walk, this.tileType, {Key? key}) : super(key: key);

  final Walk walk;
  final TileType tileType;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: InkWell(
        onTap: () => Navigator.push(context, _pageRoute()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: _weatherIcon(),
              title: _title(),
              subtitle: _subtitle(),
              trailing: tileType == TileType.calendar
                  ? GeoButton(walk)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(fullDate.format(walk.date)),
                      ],
                    ),
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: _infoRow(walk),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(Walk walk) {
    return Wrap(alignment: WrapAlignment.start, children: <Widget>[
      _ChipRanges(walk.fifteenKm),
      _ChipIcon(Icons.train, walk.transport != null),
      _ChipIcon(Icons.accessible_forward, walk.wheelchair),
      _ChipIcon(Icons.child_friendly, walk.stroller),
      _ChipIcon(Icons.map, walk.extraOrientation),
      _ChipIcon(Icons.directions_walk, walk.extraWalk),
      _ChipIcon(Icons.nature_people, walk.guided),
      _ChipIcon(Icons.directions_bike, walk.bike),
      _ChipIcon(Icons.directions_bike, walk.mountainBike),
      _ChipIcon(Icons.local_drink, walk.waterSupply),
      _ChipIcon(Icons.delete, walk.beWapp),
      _ChipIcon(Icons.sports_gymnastics, walk.adepSante)
    ]);
  }

  Widget _title() {
    if (tileType == TileType.directory) {
      return Text("${walk.city} (${walk.entity})",
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis);
    } else {
      return Text(walk.city,
          style: const TextStyle(fontWeight: FontWeight.bold));
    }
  }

  Widget _subtitle() {
    if (tileType == TileType.directory) {
      return Text(walk.getContactLabel());
    } else {
      return Text("${walk.type} - ${walk.province}");
    }
  }

  Widget _weatherIcon() {
    if (walk.isCancelled() || walk.weathers.isEmpty) {
      return TileIcon(WalkIcon(walk));
    } else {
      return WeatherIcon(walk.weathers[0]);
    }
  }

  PageRoute _pageRoute() {
    return MaterialPageRoute(builder: (context) => WalkDetailsView(walk));
  }
}

class WeatherIcon extends StatelessWidget {
  const WeatherIcon(this.weather, {Key? key}) : super(key: key);

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        getWeatherIcon(weather),
        Text("${weather.temperature.round()}°"),
      ],
    );
  }
}

class _ChipIcon extends StatelessWidget {
  const _ChipIcon(this.icon, this.value);

  final IconData icon;
  final bool value;

  @override
  Widget build(BuildContext context) {
    if (value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Chip(
            label: Icon(icon, size: 15.0),
            visualDensity: VisualDensity.compact),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _ChipRanges extends StatelessWidget {
  const _ChipRanges(this.has15km);

  final bool has15km;

  @override
  Widget build(BuildContext context) {
    String ranges = has15km ? " 5-10-15-20 km" : " 5-10-20 km";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
          avatar: const Icon(Icons.route, size: 15.0),
          label: Text(ranges, style: const TextStyle(fontSize: 12.0)),
          visualDensity: VisualDensity.compact),
    );
  }
}
