import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/views/walks/walk_info.dart';

import '../../models/walk.dart';
import 'geo_button.dart';
import 'walk_details_view.dart';
import '../../services/openweather.dart';

DateFormat fullDate = DateFormat("dd/MM", "fr_BE");

enum TileType { calendar, directory, map }

class WalkTile extends StatelessWidget {
  const WalkTile(this.walk, this.tileType, {Key? key}) : super(key: key);

  final Walk walk;
  final TileType tileType;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: walk.city,
      explicitChildNodes: true,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        semanticContainer: false,
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
    );
  }

  Widget _generateDescription(Walk walk, BuildContext context) {
    List<InlineSpan> elements = [];
    elements.add(TextSpan(text: "${walk.entity} - ${walk.province}\n"));

    if (walk.weathers.isNotEmpty) {
      elements.add(WidgetSpan(
          child: getWeatherIcon(walk.weathers.first,
              iconSize: 11.0,
              iconColor: Theme.of(context).textTheme.bodyLarge?.color)));
      elements.add(
          TextSpan(text: "${walk.weathers.first.temperature.round()}° · "));
    }

    List<InlineSpan> infos = WalkInfo.values
        .map((WalkInfo info) {
          bool value = info.walkValue(walk);

          if (WalkInfo.transport == info) {
            return null;
          }

          if (WalkInfo.fifteenKm == info) {
            return value
                ? const TextSpan(text: '5-10-15-20 km')
                : walk.isOrientation
                    ? const TextSpan(text: '4-8-12 km')
                    : const TextSpan(text: '5-10-20 km');
          }

          return value
              ? WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(info.icon, size: 13),
                )
              : null;
        })
        .whereType<InlineSpan>()
        .toList();

    for (var i = 0; i < infos.length; i++) {
      elements.add(infos[i]);
      if (i != infos.length - 1) {
        elements.add(const TextSpan(text: ' · '));
      }
    }
    return RichText(
        text: TextSpan(
            children: elements,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ));
  }

  List<Widget> getChildren(BuildContext context) {
    List<Widget> list = [
      ListTile(
        title: _title,
        subtitle: _generateDescription(walk, context),
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
                : GeoButton(walk),
      ),
    ];

    return list;
  }

  Widget get _title {
    return Text(
      walk.city,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  PageRoute _pageRoute() {
    return MaterialPageRoute(builder: (context) => WalkDetailsView(walk));
  }
}
