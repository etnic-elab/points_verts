import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/models/walk_filter.dart';

import '../list_header.dart';
import 'walks_view.dart';

class FilterPage extends StatefulWidget {
  FilterPage(this.currentFilter, this.showPlaces);

  final WalkFilter currentFilter;
  final bool showPlaces;

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  @override
  Widget build(BuildContext context) {
    WalkFilter editedFilter = widget.currentFilter;
    return Scaffold(
      appBar: AppBar(title: Text("Filtres des marches")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                widget.showPlaces
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text("Distances à partir de : "),
                            ChoiceChip(
                              label: Text("Domicile"),
                              selected:
                                  editedFilter.selectedPlace == Places.home,
                              onSelected: (bool) {
                                setState(() {
                                  editedFilter.selectedPlace = Places.home;
                                });
                              },
                            ),
                            ChoiceChip(
                              label: Text("Position"),
                              selected:
                                  editedFilter.selectedPlace == Places.current,
                              onSelected: (bool) {
                                setState(() {
                                  editedFilter.selectedPlace = Places.current;
                                });
                              },
                            )
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                Row(
                  children: <Widget>[
                    Checkbox(
                        onChanged: (bool) {
                          editedFilter.cancelledWalks = bool!;
                          setState(() {});
                        },
                        value: editedFilter.cancelledWalks),
                    Text("Afficher les marches annulées")
                  ],
                ),
                Divider(),
                ListHeader("Provinces"),
                Wrap(
                  children: [
                    _PaddedChip(editedFilter.brabantWallon, "Brabant Wallon",
                        (bool) {
                      editedFilter.brabantWallon = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.bruxelles, "Bruxelles", (bool) {
                      editedFilter.bruxelles = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.hainautEst, "Hainaut Est", (bool) {
                      editedFilter.hainautEst = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.hainautOuest, "Hainaut Ouest",
                        (bool) {
                      editedFilter.hainautOuest = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.liege, "Liège", (bool) {
                      editedFilter.liege = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.luxembourg, "Luxembourg", (bool) {
                      editedFilter.luxembourg = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.namur, "Namur", (bool) {
                      editedFilter.namur = bool;
                      setState(() {});
                    }),
                  ],
                ),
                Divider(),
                ListHeader("Afficher uniquement Points ayant..."),
                Wrap(
                  children: [
                    _PaddedChip(editedFilter.fifteenKm, "Parcours 15 km",
                        (bool) {
                      editedFilter.fifteenKm = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.wheelchair, "PMR", (bool) {
                      editedFilter.wheelchair = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.stroller, "Poussettes", (bool) {
                      editedFilter.stroller = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.extraOrientation, "+ Orientation",
                        (bool) {
                      editedFilter.extraOrientation = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.extraWalk, "+ Marche", (bool) {
                      editedFilter.extraWalk = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.guided, "Balade guidée", (bool) {
                      editedFilter.guided = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.bike, "Vélo", (bool) {
                      editedFilter.bike = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.mountainBike, "VTT", (bool) {
                      editedFilter.mountainBike = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.transport, "Train/Bus", (bool) {
                      editedFilter.transport = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.waterSupply, "Ravitaillement",
                        (bool) {
                      editedFilter.waterSupply = bool;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.beWapp, "BeWaPP", (bool) {
                      editedFilter.beWapp = bool;
                      setState(() {});
                    }),
                  ],
                ),
              ],
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                child: const Text('Réinitialiser'),
                onPressed: () {
                  WalkFilter resetFilter = WalkFilter();
                  resetFilter.selectedPlace =
                      widget.currentFilter.selectedPlace;
                  Navigator.of(context).pop(resetFilter);
                },
              ),
              TextButton(
                child: const Text('Filtrer'),
                onPressed: () {
                  Navigator.of(context).pop(editedFilter);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _PaddedChip extends StatelessWidget {
  _PaddedChip(this.value, this.label, this.callback);

  final bool value;
  final String label;
  final Function(bool) callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: FilterChip(
        label: Text(this.label),
        selected: value,
        onSelected: callback,
      ),
    );
  }
}
