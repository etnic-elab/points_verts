import 'package:flutter/material.dart';
import 'package:points_verts/models/walk_filter.dart';

import '../list_header.dart';
import 'walks_view.dart';

class FilterPage extends StatefulWidget {
  const FilterPage(this.currentFilter, this.showPlaces, {Key? key})
      : super(key: key);

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
      appBar: AppBar(title: const Text("Filtres des marches")),
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
                            const Text("Distances à partir de : "),
                            ChoiceChip(
                              label: const Text("Domicile"),
                              selected:
                                  editedFilter.selectedPlace == Places.home,
                              onSelected: (value) {
                                setState(() {
                                  editedFilter.selectedPlace = Places.home;
                                });
                              },
                            ),
                            ChoiceChip(
                              label: const Text("Position"),
                              selected:
                                  editedFilter.selectedPlace == Places.current,
                              onSelected: (value) {
                                setState(() {
                                  editedFilter.selectedPlace = Places.current;
                                });
                              },
                            )
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                Row(
                  children: <Widget>[
                    Checkbox(
                        onChanged: (v) {
                          editedFilter.cancelledWalks = v!;
                          setState(() {});
                        },
                        value: editedFilter.cancelledWalks),
                    const Text("Afficher les marches annulées")
                  ],
                ),
                const Divider(),
                const ListHeader("Provinces"),
                Wrap(
                  children: [
                    _PaddedChip(editedFilter.brabantWallon, "Brabant Wallon",
                        (value) {
                      editedFilter.brabantWallon = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.bruxelles, "Bruxelles", (value) {
                      editedFilter.bruxelles = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.hainautEst, "Hainaut Est",
                        (value) {
                      editedFilter.hainautEst = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.hainautOuest, "Hainaut Ouest",
                        (value) {
                      editedFilter.hainautOuest = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.liege, "Liège", (value) {
                      editedFilter.liege = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.luxembourg, "Luxembourg", (value) {
                      editedFilter.luxembourg = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.namur, "Namur", (value) {
                      editedFilter.namur = value;
                      setState(() {});
                    }),
                  ],
                ),
                const Divider(),
                const ListHeader("Afficher uniquement Points ayant..."),
                Wrap(
                  children: [
                    _PaddedChip(editedFilter.fifteenKm, "Parcours 15 km",
                        (value) {
                      editedFilter.fifteenKm = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.wheelchair, "PMR", (alue) {
                      editedFilter.wheelchair = alue;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.stroller, "Poussettes", (value) {
                      editedFilter.stroller = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.extraOrientation, "+ Orientation",
                        (value) {
                      editedFilter.extraOrientation = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.extraWalk, "+ Marche", (value) {
                      editedFilter.extraWalk = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.guided, "Balade guidée", (value) {
                      editedFilter.guided = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.bike, "Vélo", (value) {
                      editedFilter.bike = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.mountainBike, "VTT", (value) {
                      editedFilter.mountainBike = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.transport, "Train/Bus", (value) {
                      editedFilter.transport = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.waterSupply, "Ravitaillement",
                        (value) {
                      editedFilter.waterSupply = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.beWapp, "BeWaPP", (value) {
                      editedFilter.beWapp = value;
                      setState(() {});
                    }),
                    _PaddedChip(editedFilter.beWapp, "Adep'santé", (value) {
                      editedFilter.adepSante = value;
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
  const _PaddedChip(this.value, this.label, this.callback);

  final bool value;
  final String label;
  final Function(bool) callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: FilterChip(
        label: Text(label),
        selected: value,
        onSelected: callback,
      ),
    );
  }
}
