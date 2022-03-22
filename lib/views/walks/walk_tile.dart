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

enum TileType { calendar, directory, map }

class WalkTile extends StatelessWidget {
  const WalkTile(this.walk, this.tileType, {Key? key}) : super(key: key);

  final Walk walk;
  final TileType tileType;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: tileType == TileType.map
          ? const EdgeInsets.all(0)
          : const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      shape: tileType == TileType.map
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)))
          : null,
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

    List<Widget> _info = _infoRow(walk);
    if (!walk.isCancelled && _info.isNotEmpty) {
      _list.add(const Divider(height: 0));
      _list.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            primary: true,
            child: Row(children: _info)),
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
      return Text(walk.contactLabel);
    } else {
      return Text("${walk.type} - ${walk.province}");
    }
  }

  List<Widget> _infoRow(Walk walk) {
    List<Widget> info = [];

    if (walk.weathers.isNotEmpty) {
      info.add(_WeatherChip(walk.weathers[0]));
    }

    info.addAll(WalkInfo.values
        .map((WalkInfo _info) {
          bool _value = _info.walkValue(walk);

          if (WalkInfo.fifteenKm == _info) {
            if (!_value) {
              if (walk.isOrientation) {
                return const _ChipLabel('4-8-12 km');
              } else {
                return const _ChipLabel('5-10-20 km');
              }
            } else {
              return const _ChipLabel('5-10-15-20 km');
            }
          }

          if (!_value) {
            return null;
          } else {
            return _ChipIcon(_info.icon);
          }
        })
        .whereType<Widget>()
        .toList());

    return info;
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
  const _ChipIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
        label: Icon(icon, size: 15.0),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel(this.text, {this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
          avatar: icon != null
              ? Icon(
                  icon,
                  size: 15.0,
                )
              : null,
          label: Text(text, style: const TextStyle(fontSize: 12.0)),
          visualDensity: VisualDensity.compact),
    );
  }
}
