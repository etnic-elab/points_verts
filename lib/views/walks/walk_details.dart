import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/models/walk.dart';

import '../list_header.dart';
import 'walk_utils.dart';

class WalkDetails extends StatelessWidget {
  WalkDetails(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: <Widget>[
          ListHeader("Lieu de rendez-vous"),
          ListTile(
            dense: true,
            title: Text(walk.meetingPoint),
            subtitle: getGeoText(),
            onTap: () => launchGeoApp(walk),
          ),
          ListHeader("Groupement organisateur"),
          ListTile(
              dense: true,
              title: Text("${walk.organizer}"),
              subtitle: Text(
                  "${walk.contactFirstName} ${walk.contactLastName} - ${walk.contactPhoneNumber != null ? walk.contactPhoneNumber : ''}")),
          walk.transport != null
              ? ListHeader("Gare/Transport en commun")
              : SizedBox.shrink(),
          walk.transport != null
              ? ListTile(dense: true, title: Text(walk.transport))
              : SizedBox.shrink()
        ],
      ),
    );
  }

  Widget getGeoText() {
    if (walk.trip != null) {
      return Text(
          "À ${walk.getFormattedDistance()}, environ ${Duration(seconds: walk.trip.duration.round()).inMinutes} minutes en voiture");
    } else {
      return null;
    }
  }
}
