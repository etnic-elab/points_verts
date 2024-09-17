import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/services/openweather.dart';
import 'package:points_verts/views/list_header.dart';
import 'package:points_verts/views/walks/outline_icon_button.dart';
import 'package:points_verts/views/walks/walk_info.dart';

import '../tile_icon.dart';
import 'walk_utils.dart';

class WalkDetailsInfo extends StatelessWidget {
  const WalkDetailsInfo(this.walk, {super.key});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(5.0),
        children: <Widget>[
          _WeatherSection(walk),
          const _Spacer(height: 25.0),
          _StatusTile(walk),
          _OrganizerTile(walk),
          _DateTile(walk),
          _GeoTile(walk),
          _TransportTile(walk),
          const _Header("Informations sur les parcours"),
          _RangesTile(walk),
          _IgnTile(walk),
          _infoRow(),
        ],
      ),
    );
  }

  Widget _infoRow() {
    List<Widget> infos = [
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
        String time = "${weather.timestamp.hour}h";
        String temp = "${weather.temperature.round()}°";
        String windSpeed = "${weather.windSpeed.round()} km/h";
        widgets.add(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              time,
              semanticsLabel: "A ${time.replaceFirst(r'h', 'heure')}",
              textScaler: const TextScaler.linear(0.8),
            ),
            getWeatherIcon(weather),
            Text(
              temp,
              semanticsLabel: temp,
              textScaler: const TextScaler.linear(0.8),
            ),
            Text(windSpeed,
                semanticsLabel:
                    "Vent : ${windSpeed.replaceFirst(r'/h', ' par heure')}",
                textScaler: const TextScaler.linear(0.8))
          ],
        ));
      }
      return Semantics(
        header: true,
        label: "Météo du jour",
        explicitChildNodes: true,
        child: ListTile(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widgets)),
      );
    }
  }
}

class _DateTile extends StatelessWidget {
  _DateTile(this.walk);

  final Walk walk;
  final DateFormat fullDate = DateFormat.yMMMMEEEEd("fr_BE");

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header("Date et heures d'ouverture"),
        Semantics(
          explicitChildNodes: true,
          child: MergeSemantics(
            child: ListTile(
              leading: const TileIcon(Icon(Icons.calendar_today)),
              title:
                  Text(toBeginningOfSentenceCase(fullDate.format(walk.date))!),
              subtitle: const Text('Secrétariat ouvert de 8h à 18h',
                  semanticsLabel: 'Secrétariat ouvert de 8 heure à 18 heure'),
              trailing: OutlineIconButton(
                onPressed: () => addToCalendar(walk),
                iconData: Icons.add_alert,
                semanticLabel:
                    "Rajouter la date de l'évènement dans un calendrier externe",
              ),
              onTap: () => addToCalendar(walk),
            ),
          ),
        ),
        const _Spacer(),
      ],
    );
  }
}

class _RangesTile extends StatelessWidget {
  const _RangesTile(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    if (walk.isWalk || walk.isOrientation) {
      String title = Range.label(walk);
      WalkInfo? subtitle =
          walk.isWalk ? WalkInfo.extraOrientation : WalkInfo.extraWalk;

      return ListTile(
          leading: TileIcon(Icon(Range.icon)),
          title: Text(title),
          subtitle:
              subtitle.walkValue(walk) ? Text(subtitle.description) : null);
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
      return Column(children: [
        Semantics(
          header: true,
          child: ListTile(
              leading: TileIcon(Icon(Icons.cancel,
                  color: CompanyColors.contextualRed(context))),
              title: Text(
                "Ce Point Vert est annulé",
                style: TextStyle(color: CompanyColors.contextualRed(context)),
              )),
        ),
        const _Spacer(),
      ]);
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _GeoTile extends StatelessWidget {
  const _GeoTile(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header("Lieu de rendez-vous"),
        Semantics(
          explicitChildNodes: true,
          child: Column(
            children: [
              MergeSemantics(
                child: ListTile(
                  leading: const TileIcon(Icon(Icons.location_on)),
                  title: Text(walk.meetingPoint ?? ""),
                  subtitle: geotext,
                  trailing: OutlineIconButton(
                    onPressed: () => launchGeoApp(walk),
                    iconData: Icons.directions,
                    semanticLabel:
                        "Ouvrir dans une application de cartes externe",
                  ),
                  onTap: () => launchGeoApp(walk),
                ),
              ),
              _MeetingPointTile(walk),
            ],
          ),
        ),
        const _Spacer(),
      ],
    );
  }

  Widget? get geotext {
    String? text;

    if (walk.trip != null) {
      text =
          "À ${walk.formattedDistance}, ~${Duration(seconds: walk.trip!.duration.round()).inMinutes} min. en voiture";
    } else if (walk.distance != null && walk.distance != double.maxFinite) {
      text = "À ${walk.formattedDistance} (à vol d'oiseau)";
    } else {
      return null;
    }

    return Text(text, semanticsLabel: text.replaceFirst(r'min.', 'minutes'));
  }
}

class _IgnTile extends StatelessWidget {
  const _IgnTile(this.walk);

  final Walk walk;
  @override
  Widget build(BuildContext context) {
    return walk.ign != null
        ? ListTile(
            leading: const TileIcon(Icon(Icons.map)),
            title: Text(
              "IGN ${walk.ign}",
              semanticsLabel: "I G N ${walk.ign}",
            ),
          )
        : const SizedBox.shrink();
  }
}

class _MeetingPointTile extends StatelessWidget {
  const _MeetingPointTile(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return walk.meetingPointInfo != null
        ? ListTile(
            leading: const TileIcon(Icon(Icons.info)),
            title: Text(walk.meetingPointInfo!))
        : const SizedBox.shrink();
  }
}

class _OrganizerTile extends StatelessWidget {
  const _OrganizerTile(this.walk);

  final Walk walk;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header("Groupement organisateur"),
        Semantics(
          explicitChildNodes: true,
          child: MergeSemantics(
            child: ListTile(
              leading: const TileIcon(Icon(Icons.group)),
              title: Text(walk.organizer),
              subtitle: Text(walk.contactLabel),
              trailing: OutlineIconButton(
                onPressed: () {
                  if (walk.contactPhoneNumber != null) {
                    launchURL(
                        "tel:${walk.contactPhoneNumber!.replaceAll(' ', '')}");
                  }
                },
                iconData: Icons.call,
                semanticLabel: "Appeler ${walk.contactLabel}",
              ),
              onTap: () {
                if (walk.contactPhoneNumber != null) {
                  launchURL(
                      "tel:${walk.contactPhoneNumber!.replaceAll(' ', '')}");
                }
              },
            ),
          ),
        ),
        const _Spacer(),
      ],
    );
  }
}

class _TransportTile extends StatelessWidget {
  const _TransportTile(this.walk);

  final Walk walk;
  @override
  Widget build(BuildContext context) {
    return walk.transport != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header("Transport en commun"),
              Semantics(
                explicitChildNodes: true,
                child: ListTile(
                    leading: const TileIcon(Icon(Icons.train)),
                    title: Text(walk.transport!)),
              ),
              const _Spacer(),
            ],
          )
        : const SizedBox.shrink();
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListHeader(
      title,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}

class _Spacer extends StatelessWidget {
  const _Spacer({this.height = 15.0});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
