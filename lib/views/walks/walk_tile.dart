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
      child: ListTile(
        leading: _weatherIcon(),
        title: _title(),
        subtitle: _subtitle(),
        onTap: () => Navigator.push(context, _pageRoute()),
        trailing: tileType == TileType.calendar
            ? GeoButton(walk)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(fullDate.format(walk.date)),
                ],
              ),
      ),
    );
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
