import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/filter_page.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_tile.dart';
import '../../models/walk.dart';

DateFormat fullDate = DateFormat("dd/MM", "fr_BE");

class WalkDirectoryView extends StatefulWidget {
  const WalkDirectoryView({Key? key}) : super(key: key);

  @override
  _WalkDirectoryViewState createState() => _WalkDirectoryViewState();
}

class _WalkDirectoryViewState extends State<WalkDirectoryView> {
  Future<List<Walk>>? _walks;
  WalkFilter _filter = WalkFilter();

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    String? filterString =
        await PrefsProvider.prefs.getString("directory_walk_filter");
    WalkFilter filter;
    if (filterString != null) {
      filter = WalkFilter.fromJson(jsonDecode(filterString));
    } else {
      filter = WalkFilter();
    }
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
            List<Walk>? walks = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                title: const Text("Annuaire"),
                actions: <Widget>[
                  walks != null
                      ? IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            showSearch(
                                context: context, delegate: _DataSearch(walks));
                          },
                        )
                      : const SizedBox()
                ],
              ),
              body: walks != null
                  ? Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ActionChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(right: 4.0),
                                    child: Icon(Icons.tune, size: 16.0),
                                  ),
                                  Text("Filtres")
                                ],
                              ),
                              onPressed: () async {
                                WalkFilter? newFilter =
                                    await Navigator.of(context)
                                        .push<WalkFilter>(MaterialPageRoute(
                                            builder: (context) =>
                                                FilterPage(_filter, false)));
                                if (newFilter != null) {
                                  await PrefsProvider.prefs.setString(
                                      "directory_walk_filter",
                                      jsonEncode(newFilter));
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
                        const Divider(height: 0.0),
                        Expanded(child: _DirectoryList(walks)),
                      ],
                    )
                  : WalkListError(init),
            );
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Annuaire"),
                ),
                body: const Loading());
          }
        });
  }
}

class _DirectoryList extends StatelessWidget {
  final List<Walk> walks;

  const _DirectoryList(this.walks);

  @override
  Widget build(BuildContext context) {
    if (walks.isEmpty) {
      return const Center(
          child: Text("Aucune marche ne correspond aux critères."));
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
  final List<Walk> walks;

  _DataSearch(this.walks);

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
          })
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
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = walks;

    return _DirectoryList(suggestionList);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Walk> suggestionList = query.isEmpty
        ? walks
        : walks
            .where((p) =>
                p.city.contains(RegExp(query, caseSensitive: false)) ||
                p.entity.contains(RegExp(query, caseSensitive: false)))
            .toList();

    return _DirectoryList(suggestionList);
  }
}
