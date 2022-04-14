import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/abstractions/company_data.dart';
import 'package:points_verts/abstractions/extended_value.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/services/openweather.dart';
import 'package:points_verts/views/walks/outline_icon_button.dart';

import '../centered_tile_icon.dart';
import 'walk_utils.dart';

class WalkDetailsInfo extends StatelessWidget {
  WalkDetailsInfo(this.walk, {Key? key}) : super(key: key);

  final Walk walk;
  final DateFormat fullDate = DateFormat.yMMMMEEEEd("fr_BE");

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: _tiles(context),
      ),
    );
  }

  List<Widget> _tiles(BuildContext context) {
    //weather, cancelled, date, range, ign, meetingpoint, train/bus, contact, remaining
    List<Widget> tiles = [
      _WeatherSection(walk),
      _ExtendedValueTile(ExtendedValue<bool>(walk.isCancelled,
          layout: LayoutExtension.cancelled()
              .colored(CompanyColors.of(context).getRed()))),
      _DateTile(walk),
      _RangeTile(walk),
      _ExtendedValueTile(ExtendedValue<String?>(walk.ign,
          layout:
              LayoutExtension.ign().copyWith(description: 'IGN ${walk.ign}'))),
      _MeetingPointTile(walk),
      _ExtendedValueTile(ExtendedValue<String?>(walk.transport,
          layout: LayoutExtension.transport()
              .copyWith(description: walk.transport))),
      _OrganizerTile(walk),
    ];

    tiles.addAll([
      ExtendedValue<bool>(walk.wheelchair,
          layout: LayoutExtension.wheelchair()),
      ExtendedValue<bool>(walk.stroller, layout: LayoutExtension.stroller()),
      ExtendedValue<bool>(walk.bike, layout: LayoutExtension.bike()),
      ExtendedValue<bool>(walk.mountainBike,
          layout: LayoutExtension.mountainBike()),
      ExtendedValue<bool>(walk.guided, layout: LayoutExtension.guided()),
      ExtendedValue<bool>(walk.beWapp, layout: LayoutExtension.beWapp()),
      ExtendedValue<bool>(walk.adepSante, layout: LayoutExtension.adepSante()),
      ExtendedValue<bool>(walk.waterSupply,
          layout: LayoutExtension.waterSupply()),
    ].map((ExtendedValue value) => _ExtendedValueTile(value)));

    return tiles;
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return walk.weathers.isNotEmpty
        ? ListTile(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _widgets))
        : const SizedBox.shrink();
  }

  List<Widget> get _widgets {
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

    return widgets;
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile(this.walk, {Key? key}) : super(key: key);

  final Walk walk;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CenteredTileWidget(Icon(Icons.calendar_today)),
      title: Text(toBeginningOfSentenceCase(
          DateFormat.yMMMMEEEEd("fr_BE").format(walk.date))!),
      subtitle: const Text('Secrétariat ouvert de 8h à 18h'),
      trailing: OutlineIconButton(
        onPressed: () => addToCalendar(walk),
        iconData: Icons.edit_calendar,
      ),
    );
  }
}

class _RangeTile extends StatelessWidget {
  const _RangeTile(this.walk, {Key? key}) : super(key: key);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CenteredTileWidget(Icon(Icons.route)),
      title: Text(walk.rangeLabel(compact: false)),
      subtitle: _subtitle != null ? Text(_subtitle!) : null,
    );
  }

  String? get _subtitle {
    if (walk.isWalk) {
      return walk.extraOrientation
          ? LayoutExtension.extraOrientation().description
          : null;
    }
    return walk.extraWalk ? LayoutExtension.extraWalk().description : null;
  }
}

class _MeetingPointTile extends StatelessWidget {
  const _MeetingPointTile(this.walk, {Key? key}) : super(key: key);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return walk.meetingPoint != null
        ? ListTile(
            leading: const CenteredTileWidget(Icon(Icons.location_on)),
            title: Text(walk.meetingPoint!),
            subtitle: _subtitle.isNotEmpty ? Text(_subtitle) : null,
            isThreeLine: _isThreeLine,
            trailing: OutlineIconButton(
                onPressed: () => launchGeoApp(walk),
                iconData: Icons.directions),
          )
        : const SizedBox.shrink();
  }

  String? get _info => walk.meetingPointInfo;
  String? get _distance {
    if (walk.trip?.duration != null) {
      return "À ${walk.formattedDistance}, ~${Duration(seconds: walk.trip!.duration!.round()).inMinutes} min. en voiture";
    }

    if (walk.distance != null && walk.distance != double.maxFinite) {
      return "À ${walk.formattedDistance} (à vol d'oiseau)";
    }

    return null;
  }

  String get _subtitle {
    return [_info, _distance].whereType<String>().join('\n');
  }

  bool get _isThreeLine => _info != null && _distance != null;
}

class _OrganizerTile extends StatelessWidget {
  const _OrganizerTile(this.walk, {Key? key}) : super(key: key);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CenteredTileWidget(Icon(Icons.group)),
      title: Text(walk.organizer),
      subtitle: Text(walk.contactLabel),
      trailing: OutlineIconButton(
          onPressed: () {
            if (walk.contactPhoneNumber != null) {
              launchURL("tel:${walk.contactPhoneNumber!.replaceAll(' ', '')}");
            }
          },
          iconData: Icons.call),
    );
  }
}

class _ExtendedValueTile extends StatelessWidget {
  const _ExtendedValueTile(this.item, {Key? key}) : super(key: key);

  final ExtendedValue item;

  @override
  Widget build(BuildContext context) {
    print('${item.value} : ${item.layout?.icon != null}');
    return item.hasValue
        ? ListTile(
            iconColor: item.layout!.iconColor,
            leading: item.layout!.icon != null
                ? CenteredTileWidget(Icon(item.layout!.icon))
                : null,
            textColor: item.layout!.descriptionColor,
            title: Text(item.layout!.description),
            onTap: item.layout!.url != null
                ? () => launchURL(item.layout!.url)
                : null,
          )
        : const SizedBox.shrink();
  }
}
