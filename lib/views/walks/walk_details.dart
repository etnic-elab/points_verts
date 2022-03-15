import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/services/openweather.dart';
import 'package:points_verts/views/walks/outline_icon_button.dart';

import '../tile_icon.dart';
import 'walk_utils.dart';

class WalkDetails extends StatelessWidget {
  const WalkDetails(this.walk, {Key? key}) : super(key: key);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    DateFormat fullDate = DateFormat.yMMMMEEEEd("fr_BE");
    return Expanded(
      child: ListView(
        children: <Widget>[
          walk.weathers.isNotEmpty
              ? _WeatherSection(walk)
              : const SizedBox.shrink(),
          ListTile(
              leading: const TileIcon(Icon(Icons.calendar_today)),
              title:
                  Text(toBeginningOfSentenceCase(fullDate.format(walk.date))!),
              trailing: OutlineIconButton(
                onPressed: () => addToCalendar(walk),
                iconData: Icons.edit_calendar,
              )),
          _StatusTile(walk),
          _RangesTile(walk),
          ListTile(
            leading: const TileIcon(Icon(Icons.location_on)),
            title: Text(walk.meetingPoint != null ? walk.meetingPoint! : ""),
            subtitle: _getGeoText(),
            trailing: OutlineIconButton(
                onPressed: () => launchGeoApp(walk),
                iconData: Icons.directions),
          ),
          walk.ign != null
              ? ListTile(
                  leading: const TileIcon(Icon(Icons.map)),
                  title: Text("IGN ${walk.ign}"))
              : const SizedBox.shrink(),
          walk.meetingPointInfo != null
              ? ListTile(
                  leading: const TileIcon(Icon(Icons.info)),
                  title: Text(walk.meetingPointInfo!))
              : const SizedBox.shrink(),
          ListTile(
            leading: const TileIcon(Icon(Icons.group)),
            title: Text(walk.organizer),
            subtitle: Text(walk.getContactLabel()),
            trailing: OutlineIconButton(
                onPressed: () {
                  if (walk.contactPhoneNumber != null) {
                    launchURL(
                        "tel:${walk.contactPhoneNumber!.replaceAll(' ', '')}");
                  }
                },
                iconData: Icons.call),
          ),
          walk.transport != null
              ? ListTile(
                  leading: const TileIcon(Icon(Icons.train)),
                  title: Text(walk.transport!))
              : const SizedBox.shrink(),
          _infoRow(),
        ],
      ),
    );
  }

  Widget _infoRow() {
    return Wrap(alignment: WrapAlignment.center, children: <Widget>[
      _infoTile(Icons.accessible_forward, walk.wheelchair,
          "Parcours de 5 km accessible aux PMR"),
      _infoTile(Icons.child_friendly, walk.stroller,
          "Parcours de 5 km accessible aux landaus"),
      _infoTile(Icons.nature_people, walk.guided, "Balade guidée Nature"),
      _infoTile(Icons.directions_bike, walk.bike,
          "Parcours suppl. de vélo de +/- 20 km"),
      _infoTile(Icons.directions_bike, walk.mountainBike,
          "Parcours suppl. de VTT de +/- 20 km"),
      _infoTile(Icons.local_drink, walk.waterSupply, "Ravitaillement"),
      _infoTile(
          Icons.delete, walk.beWapp, "Participe à \"Wallonie Plus Propre\"",
          url: "https://www.walloniepluspropre.be/"),
      _infoTile(Icons.sports_gymnastics, walk.adepSante,
          "Possibilité de réaliser de petits exercices sur le parcours de 5 km")
    ]);
  }

  Widget _infoTile(IconData icon, bool value, String message, {String? url}) {
    if (value) {
      return ListTile(
          leading: TileIcon(Icon(icon)),
          title: Text(message),
          onTap: url != null
              ? () {
                  launchURL(url);
                }
              : null);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget? _getGeoText() {
    if (walk.trip != null) {
      return Text(
          "À ${walk.getFormattedDistance()}, ~${Duration(seconds: walk.trip!.duration!.round()).inMinutes} min. en voiture");
    } else if (walk.distance != null && walk.distance != double.maxFinite) {
      return Text("À ${walk.getFormattedDistance()} (à vol d'oiseau)");
    } else {
      return null;
    }
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    if (walk.weathers.isEmpty) {
      return const SizedBox();
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
    if (walk.type == 'Marche') {
      return ListTile(
        leading: const TileIcon(Icon(Icons.route)),
        title: Text(walk.fifteenKm
            ? "Parcours de 5 - 10 - 15 - 20 km"
            : "Parcours de 5 - 10 - 20 km"),
        subtitle: walk.extraOrientation
            ? const Text("Parcours suppl. d'orientation de +/- 8 km")
            : null,
      );
    } else if (walk.type == 'Orientation') {
      return ListTile(
        leading: const TileIcon(Icon(Icons.route)),
        title: const Text("Parcours de 4 - 8 - 16 km"),
        subtitle: walk.extraWalk
            ? const Text("Parcours suppl. de marche de +/- 10 km")
            : null,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    if (walk.isCancelled()) {
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
