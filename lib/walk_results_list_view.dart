import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/geo_button.dart';
import 'package:points_verts/walk_list_error.dart';

import 'loading.dart';
import 'walk.dart';
import 'walk_utils.dart';

class WalkResultsListView extends StatelessWidget {
  WalkResultsListView(this.walks, this.userPosition, this.refreshWalks);

  final Future<List<Walk>> walks;
  final Position userPosition;
  final Function refreshWalks;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Walk>>(
      future: walks,
      initialData: List<Walk>(),
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ListView.separated(
                separatorBuilder: (context, i) => Divider(height: 0.5),
                itemBuilder: (context, i) {
                  if (userPosition != null) {
                    if (i == 0) {
                      return _buildListHeader(
                          context, "Points les plus proches");
                    }
                    if (i == 6) {
                      return _buildListHeader(context, "Autres points");
                    }
                    if (i < 6) {
                      i = i - 1;
                    } else {
                      i = i - 2;
                    }
                  }
                  if (snapshot.data.length > i) {
                    return _buildListItem(context, snapshot.data[i]);
                  } else {
                    return SizedBox.shrink();
                  }
                },
                itemCount: _defineItemCount(snapshot.data));
          } else if (snapshot.hasError) {
            return WalkListError(refreshWalks);
          } else {
            return Loading();
          }
        } else {
          return Loading();
        }
      },
    );
  }

  int _defineItemCount(List<Walk> walks) {
    if (userPosition != null) {
      if (walks.length == 0) {
        return walks.length;
      } else if (walks.length > 5) {
        return walks.length + 2;
      } else {
        return walks.length + 1;
      }
    } else {
      return walks.length;
    }
  }

  Widget _buildListHeader(BuildContext context, String title) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
          child:
              Text(title, style: Theme.of(context).primaryTextTheme.subtitle)),
      padding: EdgeInsets.all(10.0),
    );
  }

  Widget _buildListItem(BuildContext context, Walk walk) {
    bool smallScreen = window.physicalSize.width <= 640;
    if (walk.details != null) {
      return ExpansionTile(
        leading: smallScreen
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [displayIcon(walk)]),
        title: Text(walk.city),
        subtitle: Text(subtitle(walk)),
        trailing: walk.isCancelled() ? Text("Annulé") : GeoButton(walk: walk),
        children: <Widget>[_buildListItemDetails(context, walk)],
      );
    } else {
      return ListTile(
        dense: smallScreen,
        leading: smallScreen
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [displayIcon(walk)]),
        title: Text(walk.city),
        subtitle: Text(subtitle(walk)),
        enabled: !walk.isCancelled(),
        trailing: walk.isCancelled() ? Text("Annulé") : GeoButton(walk: walk),
      );
    }
  }

  Widget _buildListItemDetails(BuildContext context, Walk walk) {
    List<Widget> list = [];
    if (walk.details.fifteenKm) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text('Parcours suppplémentaire de marche de 15 km'),
      ));
    }
    if (walk.details.wheelchair) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text(
            'Parcours de 5 km accessible aux personnes à mobilité réduite'),
      ));
    }
    if (walk.details.stroller) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text('Parcours de 5 km accessible aux landaus'),
      ));
    }
    if (walk.details.orientation) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Parcours supplémentaire d'orentation de +/- 8 km"),
      ));
    }
    if (walk.details.guided) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Balade guidée Nature"),
      ));
    }
    if (walk.details.bike) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Parcours supplémentaire de vélo de +/- 20 km"),
      ));
    }
    if (walk.details.mountainBike) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title:
            Text("Parcours supplémentaire de vélo tout-terrain de +/- 20 km"),
      ));
    }
    if (walk.details.supplying) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Ravitaillement"),
      ));
    }
    if (list.isEmpty) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Pas d'information supplémentaire"),
      ));
    }
    return ListView(
        shrinkWrap: true, physics: ClampingScrollPhysics(), children: list);
  }

  String subtitle(Walk walk) {
    if (walk.trip != null) {
      return '${walk.province} - ${walk.getFormattedDistance()}';
    } else {
      return walk.province;
    }
  }
}
