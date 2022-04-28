import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/abstractions/company_data.dart';
import 'package:points_verts/abstractions/extended_value.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/abstractions/service_locator.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/exceptions.dart';
import 'package:points_verts/views/list_header.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/models/walk_sort.dart';
import 'package:points_verts/views/places.dart';
import 'package:points_verts/views/walks/calendar_map_view.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_results_list.dart';
import 'package:points_verts/views/walks/walk_tile.dart';

import '../../models/walk.dart';
import 'walk_utils.dart';

const String tag = "dev.alpagaga.points_verts.WalkList";

enum _ViewType { list, map }

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

//TODO: remove current position from settings

class _CalendarViewState extends State<CalendarView> {
  final PrefsProvider _prefs = locator<PrefsProvider>();
  final DBProvider _db = locator<DBProvider>();
  final ScrollController scrollController = ScrollController();
  final double filterBarHiddenOffset = 33.0;
  final double showFABExtentThreshold = 400;

  Future<List<DateTime>?> _dates = Future.value();
  Future<List<Walk>?> _walks = Future.value();
  LatLng? _currentPosition;
  LatLng? _homePosition;
  Walk? _selectedWalk;
  WalkFilter _filter = WalkFilter();
  SortBy _sortBy = SortBy.defaultValue();
  _ViewType _viewType = _ViewType.list;
  bool _filterBarHidden = false;
  int? _results;
  Future? _searching;
  DateTime? lastRefresh;

  @override
  void initState() {
    super.initState();
    initData();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initData() async {
    List<String?> prefsStrings = await Future.wait([
      _prefs.getString(Prefs.calendarWalkFilter),
      _prefs.getString(Prefs.calendarSortBy)
    ]);
    WalkFilter? filter = prefsStrings[0] != null
        ? WalkFilter.fromJson(jsonDecode(prefsStrings[0]!))
        : null;
    SortBy? sortBy = prefsStrings[1] != null
        ? SortBy.fromJson(jsonDecode(prefsStrings[1]!))
        : null;

    setState(() {
      _filter = filter ?? _filter;
      _sortBy = sortBy ?? _sortBy;
    });

    refreshData();
  }

  Future<void> refreshData() async {
    bool doRefresh = lastRefresh == null ||
        const Duration(seconds: 30) < DateTime.now().difference(lastRefresh!);
    if (!doRefresh) return;
    try {
      await Future.wait([
        _updatePosition().catchError((error, stackTrace) =>
            setState(() => _sortBy = SortBy.defaultValue())),
        _retrieveDates()
      ]);
      updateWalks();
      setState(() => lastRefresh = DateTime.now());
    } catch (err) {
      print("Cannot retrieve dates: $err");
      _dates = Future.error(err);
    }
  }

  Future updateWalks() {
    _walks = _retrieveWalks();
    return _walks.then((walks) => setState(() => _results = walks!.length));
  }

//TODO: only show dialog if listview && drawer is closed
  Future<int?> newSearch({WalkFilter? filter, SortBy? sortBy}) async {
    if (_searching != null) {
      await _searching;
      return newSearch(filter: filter, sortBy: sortBy);
    }

    // lock
    var completer = Completer();
    _searching = completer.future;

    try {
      if (sortBy?.position ?? false) await _updatePosition(update: sortBy);

      setState(() {
        _filter = filter ?? _filter;
        _sortBy = sortBy ?? _sortBy;
      });

      await updateWalks();

      if (filter != null) {
        _prefs.setString(Prefs.calendarWalkFilter, jsonEncode(_filter));
      }

      if (sortBy != null) {
        _prefs.setString(Prefs.calendarSortBy, jsonEncode(_sortBy));
      }
    } catch (err) {
      print(err);
      if (mounted) setState((() => _results = null));
    }

    if (_viewType == _ViewType.list) scrollToTop();
    // unlock
    completer.complete();
    _searching = null;
    return _results;
  }

  Future<void> _updatePosition({SortBy? update}) async {
    SortBy sortBy = update ?? _sortBy;

    try {
      if (sortBy.position) {
        if (sortBy.type == SortType.currentPosition) {
          _currentPosition = await retrieveCurrentPosition();
        }

        if (sortBy.type == SortType.homePosition) {
          _homePosition = await retrieveHomePosition();
          if (_homePosition == null) {
            //TODO: make screen visible so that user can input homeposition instead of direct error;
            throw ArgumentError.value(_homePosition);
          }
        }

        if (mounted) setState(() {});
      }
    } catch (err) {
      print(err); //TODO: make something visible to user
      rethrow;
    }
  }

  Future _retrieveDates() {
    _dates = _db.getWalkDates();
    return _dates.then((List<DateTime>? dates) {
      if (dates!.isEmpty) throw ArgumentError.value(dates);
      if (!dates.contains(_filter.date)) {
        setState(() => _filter.date = dates.first);
      }
    });
  }

  Future<List<Walk>> _retrieveWalks() async {
    Future<List<Walk>> walks = retrieveSortedWalks(
        filter: _filter, sortBy: _sortBy, position: _position);
    try {
      _retrieveWeathers(await walks).whenComplete(() {
        if (mounted) setState(() {});
      });
    } catch (err) {
      print("Cannot retrieve weather info: $err");
    }

    return walks;
  }

  Future _retrieveWeathers(List<Walk> walks) async {
    List<Future<List<Weather>>> weathers = [];
    for (int i = 0; i < math.min(walks.length, 5); i++) {
      Walk walk = walks[i];
      Future<List<Weather>> future =
          retrieveWeather(walk).then((weather) => walk.weathers = weather);
      weathers.add(future);
    }
    await Future.wait(weathers);
  }

  void _scrollListener() {
    bool filterBarHidden = scrollController.offset > filterBarHiddenOffset;
    if (filterBarHidden != _filterBarHidden) {
      setState(() => _filterBarHidden = filterBarHidden);
    }
  }

  void scrollToTop() => scrollController.jumpTo(0.0);

  LatLng? get _position {
    switch (_sortBy.type) {
      case SortType.homePosition:
        return _homePosition;
      case SortType.currentPosition:
        return _currentPosition;
      default:
        return null;
    }
  }

  Places? get _place {
    switch (_sortBy.type) {
      case SortType.homePosition:
        return Places.home;
      case SortType.currentPosition:
        return Places.current;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_dates, _walks]),
      builder: (BuildContext context, AsyncSnapshot future) {
        if (future.hasError) {
          return Scaffold(
              drawer: const Drawer(),
              appBar: AppBar(),
              body: WalkListError(refreshData));
        }

        List<DateTime>? dates = future.data?[0];
        List<Walk>? walks = future.data?[1];
        if (dates == null || walks == null) {
          return Scaffold(
              drawer: const Drawer(),
              appBar: AppBar(),
              body: const LoadingText("Récupération des données..."));
        }

        return Scaffold(
          drawer: const Drawer(),
          endDrawer: FilterDrawer(_filter, walks.length, filterUpdate),
          body: Builder(builder: (context) {
            return Stack(
              alignment: Alignment.center,
              children: [
                RefreshIndicator(
                  onRefresh: refreshData,
                  displacement: 15.0,
                  edgeOffset: 150.0,
                  child: CustomScrollView(
                    semanticChildCount: walks.length,
                    controller: scrollController,
                    slivers: [
                      SliverAppBar(
                        elevation: 6.0,
                        pinned: true,
                        leading: Opacity(
                          opacity: 0.8,
                          child: IconButton(
                            icon: const Icon(Icons.menu),
                            splashRadius: Material.defaultSplashRadius / 1.5,
                            tooltip: 'Ouvrir le menu de navigation',
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            splashRadius: Material.defaultSplashRadius / 1.5,
                            tooltip: 'Choisir la date',
                            onPressed: () => dateUpdate(dates),
                          ),
                          IconButton(
                            splashRadius: Material.defaultSplashRadius / 1.5,
                            icon: Icon(
                              _viewType == _ViewType.list
                                  ? Icons.map
                                  : Icons.list,
                            ),
                            tooltip: _viewType == _ViewType.list
                                ? 'Voir sur la carte'
                                : 'Voir en liste',
                            onPressed: () {
                              setState(() {
                                _viewType = _viewType == _ViewType.list
                                    ? _ViewType.map
                                    : _ViewType.list;
                              });
                            },
                          ),
                        ],
                        title: SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            child: Opacity(
                              opacity: 0.8,
                              child: Tooltip(
                                  child: Text(
                                      DateFormat.yMMMEd("fr_BE")
                                          .format(_filter.date!),
                                      overflow: TextOverflow.ellipsis),
                                  message: 'La date sélectionnée'),
                            ),
                            onTap: () => dateUpdate(dates),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: FilterBar(showSort),
                      ),
                      _viewType == _ViewType.list
                          ? WalkResultSliverList(walks)
                          : SliverFillRemaining(
                              hasScrollBody: false,
                              child: CalendarMapView(walks, _position, _place,
                                  _selectedWalk, onWalkSelect, onTapMap),
                            ),
                      if (_viewType == _ViewType.list)
                        const SliverPadding(
                            padding: EdgeInsets.only(bottom: 100))
                    ],
                  ),
                ),
                if (_viewType == _ViewType.list)
                  AnimatedBuilder(
                    animation: scrollController,
                    child: FilterFAB(showSort),
                    builder: (BuildContext context, Widget? child) {
                      double _bottom = -55.0;
                      if (scrollController.position.hasContentDimensions) {
                        _bottom = math.min(
                            scrollController.position.extentBefore - 55.0,
                            15.0);
                      }
                      return Positioned(child: child!, bottom: _bottom);
                    },
                  ),
                if (_viewType == _ViewType.list)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 310),
                      offset: _results != null && _filterBarHidden == false
                          ? Offset.zero
                          : const Offset(0, 3),
                      curve: Curves.decelerate,
                      child: _ResultsBar(_results),
                    ),
                  ),
                if (_viewType == _ViewType.map && _selectedWalk != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: WalkTile(_selectedWalk!, TileType.map),
                  ),
                //TODO: change this
                if (_searching == true)
                  SimpleDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    children: const [LoadingText('Rechercher les Points...')],
                  ),
              ],
            );
          }),
        );
      },
    );
  }

  Future<int?> filterUpdate(WalkFilter newFilter) async {
    return newSearch(filter: newFilter);
  }

  Future dateUpdate(List<DateTime> allDates) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _filter.date!,
        selectableDayPredicate: (date) => allDates.contains(date),
        fieldLabelText: "Choix de la date",
        helpText: "Choix de la date",
        fieldHintText: "dd/mm/aaaa",
        errorInvalidText: "Pas de Point à la date choisie.",
        errorFormatText: "Format invalide.",
        firstDate: allDates.first,
        lastDate: allDates.last);
    if (pickedDate != null) {
      _filter.date = pickedDate;
      newSearch(filter: _filter);
    }
  }

  Future<void> showSort() async {
    SortBy? sortBy = await showModalBottomSheet(
        elevation: 6.0,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        context: context,
        builder: (context) => _SortSheet(_sortBy));

    if (sortBy != null && sortBy != _sortBy) {
      try {
        newSearch(sortBy: sortBy);
      } catch (err) {
        print(err);
      }
    }
  }

  void onWalkSelect(Walk newValue) => setState(() => _selectedWalk = newValue);

  void onTapMap() => setState(() => _selectedWalk = null);
}

class _ResultsBar extends StatelessWidget {
  const _ResultsBar(this.results, {Key? key}) : super(key: key);

  final int? results;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Center(
          child: Text(
            label,
            textScaleFactor: 1.3,
          ),
        ),
      ),
    );
  }

  String get label =>
      results != null ? '$results résultat' + (results! > 1 ? 's' : '') : '';
}

class FilterFAB extends StatelessWidget {
  const FilterFAB(this.showSort, {Key? key}) : super(key: key);

  final Future<void> Function() showSort;

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
          color: CompanyColors.greenPrimary,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(50)),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              style: _buttonStyle(isLight),
              icon: const Icon(Icons.sort),
              label: const Text('Trier'),
              onPressed: showSort,
            ),
          ),
          Text(
            '|',
            style: TextStyle(color: isLight ? Colors.white : Colors.black),
          ),
          Expanded(
            child: TextButton.icon(
              style: _buttonStyle(isLight),
              icon: const Icon(Icons.filter_list),
              label: const Text('Filtrer'),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(bool isLight) {
    return ButtonStyle(
      foregroundColor:
          MaterialStateProperty.all(isLight ? Colors.white : Colors.black),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar(this.showSort, {Key? key}) : super(key: key);

  final Future<void> Function() showSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            style: _buttonStyle,
            child: _buttonText('Trier', Icons.sort),
            onPressed: showSort,
          ),
          TextButton(
            style: _buttonStyle,
            child: _buttonText('Filtrer', Icons.filter_list),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
    );
  }

  ButtonStyle get _buttonStyle {
    return ButtonStyle(
        padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0)));
  }

  Widget _buttonText(String label, IconData icon) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(label),
        ),
        Icon(icon),
      ],
    );
  }
}

class FilterDrawer extends StatefulWidget {
  const FilterDrawer(this.filter, this.results, this.update, {Key? key})
      : super(key: key);

  final WalkFilter filter;
  final int results;
  final Future<int?> Function(WalkFilter) update;

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  bool searching = false;
  late int results;

  @override
  void initState() {
    super.initState();
    results = widget.results;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Drawer(
        elevation: 6.0,
        child: Column(
          children: [
            AppBar(
              toolbarHeight: 45,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close),
                splashColor: Colors.transparent,
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: const Text('Filtrer'),
              actions: [
                TextButton(
                  child: const Text('Réinitialiser',
                      overflow: TextOverflow.ellipsis),
                  onPressed: resetFilter,
                )
              ],
            ),
            const Divider(thickness: 2),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                children: [
                  SwitchListTile(
                      value: widget.filter.cancelledWalks.value,
                      title: Text(
                          widget.filter.cancelledWalks.layout!.description),
                      onChanged: (newValue) =>
                          updateValue(widget.filter.cancelledWalks, newValue)),
                  const Divider(
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),
                  const ListHeader("Provinces"),
                  Wrap(
                    children: _provinces,
                  ),
                  const SizedBox(height: 20),
                  const ListHeader("Afficher uniquement Points ayant..."),
                  Wrap(
                    children: _criterias,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              constraints: const BoxConstraints(
                  maxHeight: 80, minHeight: 70, minWidth: double.infinity),
              child: TextButton(
                  child: Text(
                    searchButtonLabel,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: 1.3,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(CompanyColors.greenPrimary),
                      foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        // side: BorderSide(color: Colors.red),
                      ))),
                  onPressed: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }

  String get searchButtonLabel {
    if (searching) return 'Rechercher...';
    if (results == 0) return 'Aucun résultat correspondant n\'a été trouvé';
    if (results == 1) return 'Afficher 1 résultat';
    return 'Afficher $results résultats';
  }

  List<Widget> get _provinces => widget.filter.provinces
      .map((ExtendedValue<bool> extendedValue) =>
          _PaddedChip(extendedValue, updateValue))
      .toList();
  List<Widget> get _criterias => widget.filter.criterias
      .map((ExtendedValue<bool> extendedValue) =>
          _PaddedChip(extendedValue, updateValue))
      .toList();

  void updateValue(ExtendedValue<bool> extendedValue, bool newValue) {
    extendedValue.value = newValue;
    updateFilter(widget.filter);
  }

  void updateFilter(WalkFilter newFilter) async {
    setState(() => searching = true);

    int? newResults = await widget.update(newFilter);
    if (newResults == null) {
      Navigator.pop(context);
      return;
    }

    if (mounted) {
      setState(() {
        searching = false;
        results = newResults;
      });
    }
  }

  void resetFilter() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => const _ResetDialog()).then((doFilter) {
      if (doFilter) updateFilter(widget.filter.reset());
    });
  }
}

class _ResetDialog extends StatelessWidget {
  const _ResetDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      title: const Text('Réinitialiser les affinements de recherche?'),
      content: const Text(
          'Cela réinitialisera tous les affinements et conservera votre date'),
      actions: <Widget>[
        TextButton(
          child: const Text('Annuler'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}

class _PaddedChip extends StatelessWidget {
  const _PaddedChip(this.extendedValue, this.callback);

  final ExtendedValue<bool> extendedValue;
  final Function(ExtendedValue<bool>, bool) callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: FilterChip(
        elevation: 6.0,
        avatar: extendedValue.layout!.icon != null
            ? Icon(
                extendedValue.layout!.icon,
                size: 15.0,
              )
            : null,
        label: Text(extendedValue.layout!.label),
        selected: extendedValue.value,
        onSelected: (newValue) {
          callback(extendedValue, newValue);
        },
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet(this.sortBy, {Key? key}) : super(key: key);

  final SortBy sortBy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const ListTile(
          title: Text('Trier'),
        ),
        ListView.separated(
          shrinkWrap: true,
          separatorBuilder: ((context, index) => const Divider(
                indent: 10,
                endIndent: 10,
                thickness: 1,
              )),
          itemBuilder: (context, i) {
            String title = choices.values.elementAt(i);
            SortBy value = choices.keys.elementAt(i);
            return RadioListTile(
                title: Text(title),
                value: value,
                groupValue: sortBy,
                onChanged: (newValue) =>
                    Navigator.of(context).pop(newValue as SortBy));
          },
          itemCount: choices.length,
        ),
      ]),
    );
  }

  Map<SortBy, String> get choices => {
        SortBy.fromType(SortType.city): 'Ville : A à Z',
        SortBy.fromType(SortType.province): 'Province : A à Z',
        SortBy.fromType(SortType.homePosition): 'Domicile : Les plus proches',
        SortBy.fromType(SortType.currentPosition):
            'Position actuelle : Les plus proches',
      };
}
// void _locationExceptionMessage() {
//   ScaffoldMessenger.of(context).removeCurrentSnackBar();
//   final snackBar = SnackBar(
//       content: Row(
//     children: const [
//       Padding(
//         padding: EdgeInsets.only(right: 16.0),
//         child: Icon(
//           Icons.error,
//           color: Colors.red,
//         ),
//       ),
//       Flexible(
//         child: Text(
//           "Une erreur s'est produite lors de la récupération de votre position actuelle",
//           maxLines: 3,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     ],
//   ));
//   ScaffoldMessenger.of(context).showSnackBar(snackBar);
// }
