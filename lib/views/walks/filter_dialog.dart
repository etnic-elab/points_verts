import 'package:flutter/material.dart';
import 'package:points_verts/models/walk_filter.dart';

import '../list_header.dart';
import 'place_select.dart';
import 'walks_view.dart';

Future<WalkFilter> filterDialog(
    BuildContext context, WalkFilter currentFilter, bool showPlaces) {
  return showDialog<WalkFilter>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      WalkFilter editedFilter = currentFilter;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Filtres'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  showPlaces
                      ? PlaceSelect(
                          currentPlace: editedFilter.selectedPlace,
                          onChanged: (Places place) {
                            setState(() {
                              editedFilter.selectedPlace = place;
                            });
                          })
                      : SizedBox.shrink(),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.cancelledWalks = bool;
                            setState(() {});
                          },
                          value: editedFilter.cancelledWalks),
                      Text("Marches annulées")
                    ],
                  ),
                  ListHeader("Restrictions"),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.fifteenKm = bool;
                            setState(() {});
                          },
                          value: editedFilter.fifteenKm),
                      Text("Parcours suppl. de 15 km")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.wheelchair = bool;
                            setState(() {});
                          },
                          value: editedFilter.wheelchair),
                      Text("Accessible PMR")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.stroller = bool;
                            setState(() {});
                          },
                          value: editedFilter.stroller),
                      Text("Poussettes")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.extraOrientation = bool;
                            setState(() {});
                          },
                          value: editedFilter.extraOrientation),
                      Text("Orientation")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.guided = bool;
                            setState(() {});
                          },
                          value: editedFilter.guided),
                      Text("Balade guidée")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.extraWalk = bool;
                            setState(() {});
                          },
                          value: editedFilter.extraWalk),
                      Text("Parcours suppl. de 10 km")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.bike = bool;
                            setState(() {});
                          },
                          value: editedFilter.bike),
                      Text("Vélo")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.mountainBike = bool;
                            setState(() {});
                          },
                          value: editedFilter.mountainBike),
                      Text("VTT")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.waterSupply = bool;
                            setState(() {});
                          },
                          value: editedFilter.waterSupply),
                      Text("Ravitaillement")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.beWapp = bool;
                            setState(() {});
                          },
                          value: editedFilter.beWapp),
                      Text("BeWaPP")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.transport = bool;
                            setState(() {});
                          },
                          value: editedFilter.transport),
                      Text("Transports en commun")
                    ],
                  ),
                  ListHeader("Provinces"),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.brabantWallon = bool;
                            setState(() {});
                          },
                          value: editedFilter.brabantWallon),
                      Text("Brabant Wallon")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.hainautEst = bool;
                            setState(() {});
                          },
                          value: editedFilter.hainautEst),
                      Text("Hainaut Est")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.hainautOuest = bool;
                            setState(() {});
                          },
                          value: editedFilter.hainautOuest),
                      Text("Hainaut Ouest")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.liege = bool;
                            setState(() {});
                          },
                          value: editedFilter.liege),
                      Text("Liège")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.luxembourg = bool;
                            setState(() {});
                          },
                          value: editedFilter.luxembourg),
                      Text("Luxembourg")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                          onChanged: (bool) {
                            editedFilter.namur = bool;
                            setState(() {});
                          },
                          value: editedFilter.namur),
                      Text("Namur")
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Réinitialiser'),
                onPressed: () {
                  WalkFilter resetFilter = WalkFilter();
                  resetFilter.selectedPlace = currentFilter.selectedPlace;
                  Navigator.of(context).pop(resetFilter);
                },
              ),
              FlatButton(
                child: const Text('Filtrer'),
                onPressed: () {
                  Navigator.of(context).pop(editedFilter);
                },
              ),
            ],
          );
        },
      );
    },
  );
}
