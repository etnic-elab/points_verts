import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/abstractions/company_data.dart';
import 'package:points_verts/abstractions/layout_extension.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/service_locator.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/services/openweather.dart';
import 'package:points_verts/views/widgets/loading.dart';
import 'package:collection/collection.dart';
import 'package:points_verts/views/widgets/outline_icon_button.dart';
import 'package:points_verts/views/walks/utils.dart';
import 'package:points_verts/views/widgets/centered_tile_icon.dart';

class WalkDetailsListView extends StatelessWidget {
  const WalkDetailsListView(this.walk, this.onTapMap, this.pathsLoaded,
      {Key? key})
      : super(key: key);

  final Walk walk;
  final Function onTapMap;
  final bool pathsLoaded;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[_buildMap(context, false), _Infos(walk)]);
        }
        return Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[_buildMap(context, true), _Infos(walk)]);
      },
    );
  }

  Widget _buildMap(BuildContext context, bool landscape) {
    bool hasPaths =
        walk.paths.firstWhereOrNull((_path) => _path.gpxPoints.isNotEmpty) !=
            null;
    Brightness brightness = Theme.of(context).brightness;
    Size size = MediaQuery.of(context).size;

    double height = landscape
        ? size.height
        : hasPaths
            ? max(200, size.height * 0.35)
            : max(200, size.height * 0.25);
    double width = landscape ? size.width / 2 : size.width;

    return SizedBox(
      width: width.roundToDouble(),
      height: height.roundToDouble(),
      child: pathsLoaded
          ? env.map.retrieveStaticImage(
              walk, width.round(), height.round(), brightness,
              onTap: hasPaths ? onTapMap : null)
          : const Loading(),
    );
  }
}

class _Infos extends StatelessWidget {
  _Infos(this.walk, {Key? key}) : super(key: key);

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
      _LayoutExtensionTile(LayoutExtension(
          walk.isCancelled,
          Layout.cancelled()
              .colored(CompanyColors.of(Theme.of(context).brightness).red))),
      _DateTile(walk),
      _RangeTile(walk),
      _LayoutExtensionTile(LayoutExtension(
          walk.ign, Layout.ign().copyWith(description: 'IGN ${walk.ign}'))),
      _MeetingPointTile(walk),
      _LayoutExtensionTile(LayoutExtension<String?>(walk.transport,
          Layout.transport().copyWith(description: walk.transport))),
      _OrganizerTile(walk),
    ];

    tiles.addAll([
      LayoutExtension<bool>(walk.wheelchair, Layout.wheelchair()),
      LayoutExtension<bool>(walk.stroller, Layout.stroller()),
      LayoutExtension<bool>(walk.bike, Layout.bike()),
      LayoutExtension<bool>(walk.mountainBike, Layout.mountainBike()),
      LayoutExtension<bool>(walk.guided, Layout.guided()),
      LayoutExtension<bool>(walk.beWapp, Layout.beWapp()),
      LayoutExtension<bool>(walk.adepSante, Layout.adepSante()),
      LayoutExtension<bool>(walk.waterSupply, Layout.waterSupply()),
    ].map((LayoutExtension value) => _LayoutExtensionTile(value)));

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
                children: widgets(context)))
        : const SizedBox.shrink();
  }

  List<Widget> widgets(BuildContext context) {
    List<Widget> widgets = [];
    for (Weather weather in walk.weathers) {
      widgets.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("${weather.timestamp.hour}h", textScaleFactor: 0.8),
          getWeatherIcon(weather, Theme.of(context).brightness),
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
          ? Layout.extraOrientation().description
          : null;
    }
    return walk.extraWalk ? Layout.extraWalk().description : null;
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

class _LayoutExtensionTile extends StatelessWidget {
  const _LayoutExtensionTile(this.item, {Key? key}) : super(key: key);

  final LayoutExtension item;

  @override
  Widget build(BuildContext context) {
    return item.hasValue
        ? ListTile(
            iconColor: item.layout.iconColor,
            leading: item.layout.icon != null
                ? CenteredTileWidget(Icon(item.layout.icon))
                : null,
            textColor: item.layout.descriptionColor,
            title: Text(item.layout.description!),
            onTap: item.layout.url != null
                ? () => launchURL(item.layout.url)
                : null,
          )
        : const SizedBox.shrink();
  }
}
