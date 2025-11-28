import 'package:flutter/material.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/views/walks/walk_info.dart';

import '../list_header.dart';
import 'walks_view.dart';

class FilterPage extends StatefulWidget {
  const FilterPage(this.currentFilter, this.showPlaces, {super.key});

  final WalkFilter currentFilter;
  final bool showPlaces;

  @override
  State createState() => _FilterPageState();
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
                const ListHeader("Afficher uniquement Marches ayant..."),
                Wrap(
                  children: [
                    _infoPaddedChip(editedFilter, WalkInfo.fifteenKm, (value) {
                      editedFilter.fifteenKm = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.wheelchair, (value) {
                      editedFilter.wheelchair = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.stroller, (value) {
                      editedFilter.stroller = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.extraOrientation,
                        (value) {
                      editedFilter.extraOrientation = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.extraWalk, (value) {
                      editedFilter.extraWalk = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.guided, (value) {
                      editedFilter.guided = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.bike, (value) {
                      editedFilter.bike = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.mountainBike,
                        (value) {
                      editedFilter.mountainBike = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.transport, (value) {
                      editedFilter.transport = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.waterSupply,
                        (value) {
                      editedFilter.waterSupply = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.beWapp, (value) {
                      editedFilter.beWapp = value;
                      setState(() {});
                    }),
                    _infoPaddedChip(editedFilter, WalkInfo.adepSante, (value) {
                      editedFilter.adepSante = value;
                      setState(() {});
                    }),
                  ],
                ),
              ],
            ),
          ),
          Semantics(
            container: true,
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
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
            ),
          )
        ],
      ),
    );
  }
}

_PaddedChip _infoPaddedChip(WalkFilter filter, WalkInfo walkInfo, Function(bool) callback) {
  return _PaddedChip(
    walkInfo.filterValue(filter),
    walkInfo.label,
    callback,
    icon: walkInfo.icon,
    semanticsLabel: walkInfo.description,
  );
}

class _PaddedChip extends StatelessWidget {
  const _PaddedChip(this.value, this.label, this.callback,
      {this.icon, this.semanticsLabel});

  final bool value;
  final String label;
  final Function(bool) callback;
  final IconData? icon;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: FilterChip(
        avatar: icon != null
            ? Icon(
                icon,
                size: 15.0,
              )
            : null,
        label: Text(
          label,
          semanticsLabel: semanticsLabel ?? label,
        ),
        selected: value,
        onSelected: callback,
      ),
    );
  }
}
