import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/abstractions/company_data.dart';
import 'package:points_verts/abstractions/layout_extension.dart';
import 'package:points_verts/services/service_locator.dart';
import 'package:points_verts/services/navigation.dart';
import 'package:points_verts/views/widgets/centered_tile_icon.dart';

import '../../models/walk.dart';
import 'geo_button.dart';
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
        margin: _margin,
        elevation: 0.0,
        shape: _shape,
        child: InkWell(
          borderRadius: _borderRadius,
          onTap: () => navigator.pushNamed(walkDetailRoute, arguments: walk),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                textColor:
                    walk.isCancelled ? Theme.of(context).disabledColor : null,
                title: _title,
                subtitle: _subtitle,
                trailing: _trailing(Theme.of(context).brightness),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  primary: true,
                  child: Row(children: _infoRow),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ));
  }

  EdgeInsets? get _margin {
    switch (tileType) {
      case TileType.map:
        return const EdgeInsets.all(0);
      default:
        return const EdgeInsets.all(4.0);
    }
  }

  BorderRadius? get _borderRadius {
    switch (tileType) {
      case TileType.map:
        return const BorderRadius.vertical(
            top: Radius.circular(20), bottom: Radius.zero);
      default:
        return null;
    }
  }

  ShapeBorder? get _shape {
    switch (tileType) {
      case TileType.map:
        return RoundedRectangleBorder(borderRadius: _borderRadius!);
      default:
        return null;
    }
  }

  Widget get _title {
    switch (tileType) {
      case TileType.directory:
        return Text("${walk.city} (${walk.entity})",
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis);
      default:
        return Text(walk.city,
            style: const TextStyle(fontWeight: FontWeight.bold));
    }
  }

  Widget get _subtitle {
    switch (tileType) {
      case TileType.directory:
        return Text(walk.contactLabel);
      default:
        return Text("${walk.type} - ${walk.province}");
    }
  }

  Widget _trailing(Brightness brightness) {
    if (walk.isCancelled) {
      return CenteredTileWidget(
        child: Text("Annulé",
            style: TextStyle(color: CompanyColors.of(brightness).red)),
      );
    }

    switch (tileType) {
      case TileType.directory:
        return CenteredTileWidget(child: Text(fullDate.format(walk.date)));
      default:
        return GeoButton(walk);
    }
  }

  List<Widget> get _infoRow {
    List<Widget> info = [];

    if (walk.weathers.isNotEmpty) info.add(_WeatherChip(walk.weathers[0]));
    info.add(
        _ChipLabel(walk.rangeLabel(compact: true), disabled: walk.isCancelled));
    info.addAll([
      LayoutExtension(walk.transport?.isNotEmpty ?? false, Layout.transport()),
      LayoutExtension(walk.wheelchair, Layout.wheelchair()),
      LayoutExtension(walk.stroller, Layout.stroller()),
      LayoutExtension(walk.bike, Layout.bike()),
      LayoutExtension(walk.mountainBike, Layout.mountainBike()),
      LayoutExtension(walk.guided, Layout.guided()),
      LayoutExtension(walk.beWapp, Layout.beWapp()),
      LayoutExtension(walk.adepSante, Layout.adepSante()),
      LayoutExtension(walk.waterSupply, Layout.waterSupply()),
    ]
        .map((LayoutExtension layoutExtension) => layoutExtension.value == true
            ? _ChipIcon(layoutExtension.layout.icon!,
                disabled: walk.isCancelled)
            : null)
        .whereType<Widget>()
        .toList());
    return info;
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
        avatar: getWeatherIcon(weather, Theme.of(context).brightness,
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
