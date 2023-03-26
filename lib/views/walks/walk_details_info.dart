import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/services/openweather.dart';
import 'package:points_verts/views/walks/outline_icon_button.dart';
import 'package:points_verts/views/walks/walk_info.dart';

import '../tile_icon.dart';
import 'walk_utils.dart';

class WalkDetailsInfo extends StatelessWidget {
  const WalkDetailsInfo(this.walk, {Key? key}) : super(key: key);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    DateFormat fullDate = DateFormat.yMMMMEEEEd("fr_BE");
    return Expanded(
      child: ListView(
        children: <Widget>[
          _WeatherSection(walk),
          ListTile(
              leading: const TileIcon(Icon(Icons.calendar_today)),
              title: const Text("Date de l'activité"),
              subtitle:
                  Text(toBeginningOfSentenceCase(fullDate.format(walk.date))!),
              trailing: OutlineIconButton(
                onPressed: () => addToCalendar(walk),
                semanticLabel: "Ajouter cette activité à votre calendrier",
                iconData: Icons.edit_calendar,
              )),
          _StatusTile(walk),
          _RangesTile(walk),
          ListTile(
            leading: const TileIcon(Icon(Icons.location_on)),
            title: const Text("Lieu de rendez-vous"),
            subtitle: Text(walk.meetingPoint ?? ""),
            trailing: OutlineIconButton(
                onPressed: () => launchGeoApp(walk),
                semanticLabel:
                    "Lancer la navigation vers le lieu de rendez-vous",
                iconData: Icons.directions),
          ),
          walk.ign != null
              ? ListTile(
                  leading: const TileIcon(Icon(Icons.map)),
                  title: const Text("Carte topographique"),
                  subtitle: Text("IGN ${walk.ign}"))
              : const SizedBox.shrink(),
          walk.meetingPointInfo != null
              ? ListTile(
                  leading: const TileIcon(Icon(Icons.info)),
                  title: const Text("Remarques"),
                  subtitle: Text(walk.meetingPointInfo!))
              : const SizedBox.shrink(),
          ListTile(
            leading: const TileIcon(Icon(Icons.group)),
            title: const Text("Groupement organisateur"),
            subtitle: Text(walk.organizer),
          ),
          walk.contactPhoneNumber != null
              ? ListTile(
                  leading: const TileIcon(Icon(Icons.person)),
                  title: const Text("Personne de contact"),
                  subtitle: Text(walk.contactLabel),
                  trailing: OutlineIconButton(
                      onPressed: () {
                        if (walk.contactPhoneNumber != null) {
                          launchURL(
                              "tel:${walk.contactPhoneNumber!.replaceAll(' ', '')}");
                        }
                      },
                      semanticLabel: "Appeler la personne de contact",
                      iconData: Icons.call),
                )
              : const SizedBox.shrink(),
          walk.transport != null
              ? ListTile(
                  leading: const TileIcon(Icon(Icons.train)),
                  title: const Text("Gare/Transport en commun"),
                  subtitle: Text(walk.transport!))
              : const SizedBox.shrink(),
          _infoRow(),
        ],
      ),
    );
  }

  Widget _infoRow() {
    List<Widget> infos = [
      WalkInfo.extraOrientation,
      WalkInfo.extraWalk,
      WalkInfo.wheelchair,
      WalkInfo.stroller,
      WalkInfo.guided,
      WalkInfo.bike,
      WalkInfo.mountainBike,
      WalkInfo.waterSupply,
      WalkInfo.beWapp,
      WalkInfo.adepSante
    ].map((WalkInfo info) => _infoTile(info)).toList();

    return Wrap(alignment: WrapAlignment.center, children: infos);
  }

  Widget _infoTile(WalkInfo info) {
    if (info.walkValue(walk)) {
      return ListTile(
          leading: TileIcon(Icon(info.icon)),
          title: Text(info.description),
          onTap: info.url != null
              ? () {
                  launchURL(info.url);
                }
              : null);
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    if (walk.weathers.isEmpty) {
      return const SizedBox.shrink();
    } else {
      List<Widget> widgets = [];
      for (Weather weather in walk.weathers) {
        widgets.add(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("${weather.timestamp.hour}h", textScaleFactor: 0.8),
            getWeatherIcon(weather),
            Text("${weather.temperature.round()}°", textScaleFactor: 0.8),
            Text("${weather.windSpeed.round()} km/h", textScaleFactor: 0.8)
          ],
        ));
      }
      return ListTile(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widgets));
    }
  }
}

class _RangesTile extends StatelessWidget {
  const _RangesTile(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    if (walk.isWalk || walk.isOrientation) {
      String description = Range.label(walk, compact: true);

      return ListTile(
          leading: TileIcon(Icon(Range.icon)),
          title: const Text("Activité principale"),
          subtitle: Text(
              (walk.isWalk ? "Marche : " : "Orientation : ") + description));
    }

    return const SizedBox.shrink();
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    if (walk.isCancelled) {
      return ListTile(
          leading: TileIcon(
              Icon(Icons.cancel, color: CompanyColors.contextualRed(context))),
          title: Text(
            "Ce Point Vert est annulé",
            style: TextStyle(color: CompanyColors.contextualRed(context)),
          ));
    } else {
      return const SizedBox.shrink();
    }
  }
}
