import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/views/walks/walk_info.dart';

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
          children: _children,
        ),
      ),
    );
  }

  List<Widget> get _children {
    List<Widget> _list = [
      ListTile(
        leading: TileIcon(WalkIcon(walk)),
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
      )
    ];

    if (!walk.isCancelled()) {
      _list.add(const Divider(height: 0));
      _list.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: _infoRow(walk),
      ));
    }

    return _list;
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

  Widget _infoRow(Walk walk) {
    List<Widget> _infos = WalkInfo.values
        .map((WalkInfo info) => info == WalkInfo.fifteenKm
            ? _ChipLabel("+ 15 km", info.walkValue(walk))
            : _ChipIcon(info.icon, info.walkValue(walk)))
        .toList();

    if (walk.weathers.isNotEmpty) {
      _infos = [_WeatherChip(walk.weathers[0]), ..._infos];
    }

    return Wrap(alignment: WrapAlignment.start, children: _infos);
  }

  PageRoute _pageRoute() {
    return MaterialPageRoute(builder: (context) => WalkDetailsView(walk));
  }
}

class _WeatherChip extends StatelessWidget {
  const _WeatherChip(this.weather, {Key? key}) : super(key: key);

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
        avatar: getWeatherIcon(weather,
            iconSize: 15.0,
            iconColor: Theme.of(context).textTheme.bodyText1?.color),
        label: Text("${weather.temperature.round()}°"),
        visualDensity: VisualDensity.compact,
      ),
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

class _ChipLabel extends StatelessWidget {
  const _ChipLabel(this.text, this.value);

  final String text;
  final bool value;

  @override
  Widget build(BuildContext context) {
    if (value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Chip(
            label: Text(text, style: const TextStyle(fontSize: 12.0)),
            visualDensity: VisualDensity.compact),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
