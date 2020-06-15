import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_tile.dart';
import 'package:points_verts/views/walks/walk_utils.dart';
import '../../models/walk.dart';

DateFormat fullDate = DateFormat("dd/MM", "fr_BE");

class WalkDirectoryView extends StatefulWidget {
  @override
  _WalkDirectoryViewState createState() => _WalkDirectoryViewState();
}

class _WalkDirectoryViewState extends State<WalkDirectoryView> {
  Future<List<Walk>> walks;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    setState(() {
      walks = null;
    });
    await updateWalks();
    setState(() {
      walks = DBProvider.db.getSortedWalks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: walks,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<Walk> walks = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                title: const Text("Annuaire"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context, delegate: _DataSearch(walks));
                    },
                  )
                ],
              ),
              body: walks.isNotEmpty
                  ? _DirectoryList(walks)
                  : WalkListError(init),
            );
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Annuaire"),
                ),
                body: Loading());
          }
        });
  }
}

class _DirectoryList extends StatelessWidget {
  final List<Walk> walks;

  _DirectoryList(this.walks);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) =>
          WalkTile(walks[index], TileType.directory),
      itemCount: walks.length,
    );
  }
}

class _DataSearch extends SearchDelegate<String> {
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
          icon: Icon(Icons.clear),
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
