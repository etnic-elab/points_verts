import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/views/walks/walk_info.dart';

import '../tile_icon.dart';
import '../../models/walk.dart';
import 'geo_button.dart';
import 'walk_details_view.dart';
import 'walk_icon.dart';
import '../../models/weather.dart';
import '../../services/openweather.dart';

DateFormat fullDate = DateFormat("dd/MM", "fr_BE");

enum TileType { calendar, directory, map }

class WalkTile extends StatelessWidget {
  const WalkTile(this.walk, this.tileType, {super.key});

  final Walk walk;
  final TileType tileType;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: walk.city,
      explicitChildNodes: true,
      child: Stack(
        children: [
          Card(
            semanticContainer: false,
            margin: tileType == TileType.map
                ? const EdgeInsets.all(0)
                : const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            shape: tileType == TileType.map
                ? const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)))
                : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8.0, 18.0, 8.0),
              child: MergeSemantics(
                child: Semantics(
                  button: true,
                  hint: "Ouvrir la page de détail de l'évènement",
                  child: InkWell(
                    onTap: () => Navigator.push(context, _pageRoute()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: getChildren(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
          tileType == TileType.directory || walk.isCancelled
              ? const SizedBox.shrink()
              : Positioned(
                  right: 20,
                  top: 20,
                  child: GeoButton(walk),
                ),
        ],
      ),
    );
  }

  List<Widget> getChildren(BuildContext context) {
    List<Widget> list = [
      ListTile(
        enabled: !walk.isCancelled,
        title: _title,
        subtitle: _subtitle,
        trailing: tileType == TileType.directory
            ? Text(fullDate.format(walk.date))
            : walk.isCancelled
                ? ExcludeSemantics(
                    child: Text(
                      "Annulé",
                      style: TextStyle(
                          color: CompanyColors.contextualRed(context)),
                    ),
                  )
                : const SizedBox.shrink(),
      ),
    ];

    List<Widget> info = _infoRow(walk);
    if (!walk.isCancelled && info.isNotEmpty) {
      list.add(const Divider(height: 0));
      list.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            primary: true,
            child: Row(children: info)),
      ));
    }

    return list;
  }

  Widget get _title {
    return Text(
      walk.city,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget get _subtitle {
    String text = "${walk.type} - ${walk.province}";
    return Text(text);
  }

  List<Widget> _infoRow(Walk walk) {
    List<Widget> info = [];

    if (walk.weathers.isNotEmpty) info.add(_WeatherChip(walk.weathers.first));

    info.addAll(WalkInfo.values
        .map((WalkInfo info) {
          bool value = info.walkValue(walk);

          if (WalkInfo.fifteenKm == info) {
            return value
                ? const _ChipLabel('5-10-15-20 km')
                : walk.isOrientation
                    ? const _ChipLabel('4-8-12 km')
                    : const _ChipLabel('5-10-20 km');
          }

          return value ? _ChipIcon(info.icon, info.description) : null;
        })
        .whereType<Widget>()
        .toList());

    if (walk.paths.isNotEmpty) {
      info.add(const _ChipIcon(Icons.near_me, 'Tracé GPX disponible'));
    }

    return info;
  }

  PageRoute _pageRoute() {
    return MaterialPageRoute(builder: (context) => WalkDetailsView(walk));
  }
}

class _WeatherChip extends StatelessWidget {
  const _WeatherChip(this.weather);

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
        avatar: getWeatherIcon(weather,
            iconSize: 15.0,
            iconColor: Theme.of(context).textTheme.bodyLarge?.color),
        label: Text("${weather.temperature.round()}°"),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  const _ChipIcon(this.icon, this.semanticLabel);

  final IconData icon;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
        label: Icon(icon, size: 15.0, semanticLabel: semanticLabel),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
          label: Text(
            text,
            style: const TextStyle(fontSize: 12.0),
            semanticsLabel: text.replaceAll(r'-', ', '),
          ),
          visualDensity: VisualDensity.compact),
    );
  }
}
