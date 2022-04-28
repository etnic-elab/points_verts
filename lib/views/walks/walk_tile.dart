import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/abstractions/extended_value.dart';

import '../../models/walk.dart';
import 'geo_button.dart';
import 'walk_details_view.dart';
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
    return Material(
      shape: _shape,
      elevation: tileType == TileType.map ? 6.0 : 0.0,
      child: ListTile(
        minVerticalPadding: 16.0,
        shape: _shape,
        onTap: () => Navigator.push(context, _pageRoute()),
        title: _title,
        textColor: walk.isCancelled ? Theme.of(context).disabledColor : null,
        isThreeLine: true,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _subtitle,
            Wrap(
              children: _infoRow(walk),
            )
          ],
        ),
        trailing: tileType == TileType.directory
            ? Text(fullDate.format(walk.date))
            : GeoButton(walk),
      ),
    );
  }

  ShapeBorder? get _shape {
    switch (tileType) {
      case TileType.map:
        return const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(20), bottom: Radius.zero));
      default:
        return null;
    }
  }

  Widget get _title {
    if (tileType == TileType.directory) {
      return Text("${walk.city} (${walk.entity})",
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis);
    } else {
      return Text(walk.city,
          style: const TextStyle(fontWeight: FontWeight.bold));
    }
  }

  Widget get _subtitle {
    if (tileType == TileType.directory) {
      return Text(walk.contactLabel);
    } else {
      return Text("${walk.type} - ${walk.province}");
    }
  }

  List<Widget> _infoRow(Walk walk) {
    List<Widget> info = [];

    if (walk.weathers.isNotEmpty) info.add(_WeatherChip(walk.weathers[0]));
    info.add(
        _ChipLabel(walk.rangeLabel(compact: true), disabled: walk.isCancelled));
    info.addAll([
      ExtendedValue(walk.transport?.isNotEmpty ?? false,
          layout: LayoutExtension.transport()),
      ExtendedValue(walk.wheelchair, layout: LayoutExtension.wheelchair()),
      ExtendedValue(walk.stroller, layout: LayoutExtension.stroller()),
      ExtendedValue(walk.bike, layout: LayoutExtension.bike()),
      ExtendedValue(walk.mountainBike, layout: LayoutExtension.mountainBike()),
      ExtendedValue(walk.guided, layout: LayoutExtension.guided()),
      ExtendedValue(walk.beWapp, layout: LayoutExtension.beWapp()),
      ExtendedValue(walk.adepSante, layout: LayoutExtension.adepSante()),
      ExtendedValue(walk.waterSupply, layout: LayoutExtension.waterSupply()),
    ]
        .map((ExtendedValue extended) => extended.value == true
            ? _ChipIcon(extended.layout!.icon!, disabled: walk.isCancelled)
            : null)
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
  const _ChipIcon(this.icon, {this.disabled = false});

  final IconData icon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
        label: Icon(
          icon,
          size: 15.0,
          color: disabled ? Theme.of(context).disabledColor : null,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel(this.text, {this.icon, this.disabled = false});

  final String text;
  final IconData? icon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
          avatar: icon != null
              ? Icon(
                  icon,
                  size: 15.0,
                  color: disabled ? Theme.of(context).disabledColor : null,
                )
              : null,
          labelStyle: disabled
              ? TextStyle(color: Theme.of(context).disabledColor)
              : null,
          label: Text(text, style: const TextStyle(fontSize: 12.0)),
          visualDensity: VisualDensity.compact),
    );
  }
}
