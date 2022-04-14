import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:points_verts/views/walks/filter_page.dart';
import 'package:points_verts/models/walk_sort.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_results_list.dart';

import 'dates_dropdown.dart';
import '../../models/walk.dart';
import 'walk_results_list_view.dart';
import 'walk_results_map_view.dart';
import 'walk_utils.dart';

const String tag = "dev.alpagaga.points_verts.WalkList";

enum _ViewType { list, map }
// enum UpdateStatus { success, error }

class WalksView extends StatefulWidget {
  const WalksView({Key? key}) : super(key: key);

  @override
  _WalksViewState createState() => _WalksViewState();
}

//TODO: check if fetchData is launched when back from background
//TODO: remove current position from settings

class _WalksViewState extends State<WalksView> {
  final PrefsProvider _prefs = locator<PrefsProvider>();
  final DBProvider _db = locator<DBProvider>();
  final ScrollController scrollController = ScrollController();
  final double filterBarOffset = 33.0;

  Future<List<DateTime>>? _dates;
  Future<List<Walk>>? _currentWalks;
  LatLng? _currentPosition;
  LatLng? _homePosition;
  WalkFilter _filter = WalkFilter();
  SortBy _sortBy = SortBy.defaultValue();
  _ViewType _viewType = _ViewType.list;
  bool _reachedFilterBarOffset = false;
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

    _refreshData();
  }

  Future<void> _refreshData() async {
    bool doRefresh = lastRefresh == null ||
        const Duration(seconds: 30) < DateTime.now().difference(lastRefresh!);
    if (!doRefresh) return;
    try {
      await Future.wait([_updatePosition(), _retrieveDates()]);
      updateWalks();
      setState(() => lastRefresh = DateTime.now());
    } on DatesNotFoundException catch (err) {
      print("Cannot retrieve dates: $err");
      if (mounted) setState(() => _dates = Future.error(err));
    }
  }

  void updateWalks() {
    _currentWalks = _retrieveWalks();
    _currentWalks!.then(
        (walks) => _resultsSnackbar(!_reachedFilterBarOffset, walks.length));
  }

  Future<void> _updatePosition({SortBy? onErrorValue}) async {
    try {
      if (_sortBy.type == SortType.currentPosition) {
        _currentPosition = await retrieveCurrentPosition();
      }

      if (_sortBy.type == SortType.homePosition) {
        _homePosition = await retrieveHomePosition();
        if (_homePosition == null) throw ArgumentError.value(_homePosition);
      }

      if (mounted) setState(() {});
    } catch (err) {
      setState(() => _sortBy = onErrorValue ?? SortBy.defaultValue());
    }
  }

  Future<List<DateTime>?> _retrieveDates() {
    _dates = _db.getWalkDates();
    return _dates!.then((List<DateTime> dates) async {
      if (dates.isEmpty) throw ArgumentError.value(dates);
      if (!dates.contains(_filter.date)) {
        setState(() => _filter.date = dates.first);
      }
    }).catchError((err) {
      throw DatesNotFoundException('$err');
    });
  }

  Future<List<Walk>> _retrieveWalks() async {
    Future<List<Walk>> walks = retrieveSortedWalks(
        filter: _filter, sortBy: _sortBy, position: _selectedPosition);
    try {
      _retrieveWeathers(await walks).then((_) {
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
    return Future.wait(weathers);
  }

  void _scrollListener() {
    bool showFAB = scrollController.offset > filterBarOffset;
    bool visibleSnackbar = scrollController.offset < filterBarOffset - 2.0;
    if (showFAB != _reachedFilterBarOffset) {
      setState(() => _reachedFilterBarOffset = showFAB);
    }
    _currentWalks
        ?.then((walks) => _resultsSnackbar(visibleSnackbar, walks.length));
  }

  LatLng? get _selectedPosition {
    switch (_sortBy.type) {
      case SortType.homePosition:
        return _homePosition;
      case SortType.currentPosition:
        return _currentPosition;
      default:
        return null;
    }
  }

  void _resultsSnackbar(bool visible, int results) async {
    if (visible == true) {
      bool isLight = Theme.of(context).brightness == Brightness.light;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar = SnackBar(
          elevation: 0,
          padding: const EdgeInsets.all(18),
          backgroundColor: isLight ? Colors.white : Colors.black,
          duration: const Duration(days: 10),
          content: Text(_resultsSnackbarLabel(results),
              textAlign: TextAlign.center,
              textScaleFactor: 1.3,
              style: TextStyle(color: isLight ? Colors.black : Colors.white)));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  String _resultsSnackbarLabel(int results) =>
      '$results résultat' + (results > 1 ? 's' : '');

  Function get refreshData => _refreshData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dates,
      builder: (BuildContext context, AsyncSnapshot dates) {
        if (dates.hasError) return WalkListError(refreshData);
        if (!dates.hasData) {
          return const LoadingText("Récupération des données...");
        }

        return FutureBuilder(
          future: _currentWalks,
          builder: (BuildContext context, AsyncSnapshot<List<Walk>> walks) {
            int results = walks.data?.length ?? 0;
            return Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton:
                  FilterFAB(_reachedFilterBarOffset && results > 0),
              drawer: const Drawer(),
              endDrawer: walks.hasData
                  ? FilterDrawer(_filter, walks.data!.length, filterUpdate)
                  : null,
              body: NestedScrollView(
                controller: scrollController,
                headerSliverBuilder: (context, innerBoxScrolled) => [
                  SliverAppBar(
                    elevation: 4,
                    forceElevated: innerBoxScrolled,
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
                        onPressed: () {},
                      ),
                      IconButton(
                        splashRadius: Material.defaultSplashRadius / 1.5,
                        icon: Icon(
                          _viewType == _ViewType.list ? Icons.map : Icons.list,
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
                        child: const Opacity(
                          opacity: 0.8,
                          child: Tooltip(
                              child:
                                  Text('date', overflow: TextOverflow.ellipsis),
                              message: 'La date'),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ),
                  if (walks.hasData)
                    const SliverToBoxAdapter(
                      child: FilterBar(),
                    ),
                ],
                body: walks.hasError
                    ? WalkListError(refreshData)
                    : walks.hasData
                        ? RefreshIndicator(
                            displacement: 25.0,
                            onRefresh: _refreshData,
                            child: WalkResultsList(walks.data!),
                          )
                        : const LoadingText('Chargement des points...'),
              ),
            );
          },
        );
      },
    );
  }

  Future<int?> filterUpdate(WalkFilter newFilter) async {
    if (mounted) setState(() => _filter = newFilter);
    updateWalks();
    try {
      List<dynamic> futures = await Future.wait([
        _currentWalks!,
        _prefs.setString(Prefs.calendarWalkFilter, jsonEncode(newFilter)),
      ]);
      if (scrollController.offset > filterBarOffset) {
        scrollController.animateTo(filterBarOffset + 0.1,
            duration: const Duration(milliseconds: 300), curve: Curves.linear);
      }

      return futures[0].length;
    } catch (err) {
      return null;
    }
  }
}

class FilterFAB extends StatelessWidget {
  const FilterFAB(this.isVisible, {Key? key}) : super(key: key);

  final bool isVisible;
  final Offset _visible = Offset.zero;
  final Offset _invisible = const Offset(0, 3);

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 350),
      offset: isVisible ? _visible : _invisible,
      child: Container(
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
                onPressed: () {},
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
  const FilterBar({Key? key}) : super(key: key);

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
            onPressed: () {},
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
        elevation: 8,
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
        //TODO: check elevation
        elevation: 5,
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