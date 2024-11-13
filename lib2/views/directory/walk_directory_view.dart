import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/filter_page.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_tile.dart';
import '../../models/walk.dart';
import '../app_bar_logo.dart';

DateFormat fullDate = DateFormat('dd/MM', 'fr_BE');

class WalkDirectoryView extends StatefulWidget {
  const WalkDirectoryView({super.key});

  @override
  State createState() => _WalkDirectoryViewState();
}

class _WalkDirectoryViewState extends State<WalkDirectoryView> {
  Future<List<Walk>>? _walks;
  WalkFilter _filter = WalkFilter();

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    final String? filterString =
        await PrefsProvider.prefs.getString(Prefs.directoryWalkFilter);
    WalkFilter filter;
    filter = WalkFilter.fromJson(jsonDecode(filterString));
      setState(() {
      _walks = null;
      _filter = filter;
    });
    setState(() {
      _walks = DBProvider.db.getSortedWalks(filter: _filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _walks,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final List<Walk>? walks = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                title: const Row(
                  children: [
                    AppBarLogo(),
                    Text('Annuaire'),
                  ],
                ),
                actions: <Widget>[
                  if (walks != null) IconButton(
                          icon: const Icon(
                            Icons.search,
                            semanticLabel: 'Rechercher par texte',
                          ),
                          onPressed: () {
                            showSearch(
                                context: context, delegate: _DataSearch(walks),);
                          },
                        ) else const SizedBox(),
                ],
              ),
              body: walks != null
                  ? Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ActionChip(
                              avatar: const Icon(Icons.tune),
                              label: const Text('Filtres'),
                              onPressed: () async {
                                final newFilter =
                                    await Navigator.of(context)
                                        .push<WalkFilter>(MaterialPageRoute(
                                            builder: (context) =>
                                                FilterPage(_filter, false),),);
                                if (newFilter != null) {
                                  await PrefsProvider.prefs.setString(
                                      Prefs.directoryWalkFilter,
                                      jsonEncode(newFilter),);
                                  setState(() {
                                    _filter = newFilter;
                                    _walks = DBProvider.db
                                        .getSortedWalks(filter: newFilter);
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(child: _DirectoryList(walks)),
                      ],
                    )
                  : WalkListError(init),
            );
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: const Row(
                    children: [
                      AppBarLogo(),
                      Text('Annuaire'),
                    ],
                  ),
                ),
                body: const Loading(),);
          }
        },);
  }
}

class _DirectoryList extends StatelessWidget {

  const _DirectoryList(this.walks);
  final List<Walk> walks;

  @override
  Widget build(BuildContext context) {
    if (walks.isEmpty) {
      return const Center(
          child: Text('Aucune marche ne correspond aux critères.'),);
    } else {
      return ListView.builder(
        itemBuilder: (context, index) =>
            WalkTile(walks[index], TileType.directory),
        itemCount: walks.length,
      );
    }
  }
}

class _DataSearch extends SearchDelegate<String?> {

  _DataSearch(this.walks);
  final List<Walk> walks;

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  String get searchFieldLabel => 'Rechercher';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        },);
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = walks;

    return _DirectoryList(suggestionList);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? walks
        : walks
            .where((p) =>
                p.city.toLowerCase().contains(query.toLowerCase()) ||
                p.entity.toLowerCase().contains(query.toLowerCase()),)
            .toList();

    return _DirectoryList(suggestionList);
  }
}
