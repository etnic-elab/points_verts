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

class WalkDetails extends StatelessWidget {
  const WalkDetails(this.walk, {Key? key}) : super(key: key);

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
              title:
                  Text(toBeginningOfSentenceCase(fullDate.format(walk.date))!)),
          _StatusTile(walk),
          _RangesTile(walk),
          ListTile(
            leading: const TileIcon(Icon(Icons.location_on)),
            title: Text(walk.meetingPoint ?? ""),
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
    List<Widget> _infos = [
      WalkInfo.wheelchair,
      WalkInfo.stroller,
      WalkInfo.guided,
      WalkInfo.bike,
      WalkInfo.mountainBike,
      WalkInfo.waterSupply,
      WalkInfo.beWapp,
      WalkInfo.adepSante
    ].map((WalkInfo info) => _infoTile(info)).toList();

    return Wrap(alignment: WrapAlignment.center, children: _infos);
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
      String _title = RouteRange.label(walk);
      WalkInfo? _subtitle =
          walk.isWalk ? WalkInfo.extraOrientation : WalkInfo.extraWalk;

      return ListTile(
          leading: TileIcon(Icon(RouteRange.icon)),
          title: Text(_title),
          subtitle:
              _subtitle.walkValue(walk) ? Text(_subtitle.description) : null);
    }

    return const SizedBox.shrink();
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
