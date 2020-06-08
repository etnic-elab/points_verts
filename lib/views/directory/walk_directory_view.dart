import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/tile_icon.dart';
import 'package:points_verts/views/walks/walk_icon.dart';
import '../../models/walk.dart';
import '../walks/walk_details_view.dart';

DateFormat fullDate = DateFormat("dd/MM", "fr_BE");

class WalkDirectoryView extends StatefulWidget {
  @override
  _WalkDirectoryViewState createState() => _WalkDirectoryViewState();
}

class _WalkDirectoryViewState extends State<WalkDirectoryView> {
  final Future<List<Walk>> walks = DBProvider.db.getSortedWalks();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: walks,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Annuaire"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: _DataSearch(snapshot.data));
                    },
                  )
                ],
              ),
              body: _DirectoryList(snapshot.data),
            );
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Annuaire"),
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
      itemBuilder: (context, index) => _DirectoryTile(walks[index]),
      itemCount: walks.length,
    );
  }
}

class _DirectoryTile extends StatelessWidget {
  final Walk walk;

  _DirectoryTile(this.walk);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => WalkDetailsView(walk))),
        leading: TileIcon(WalkIcon(walk)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(fullDate.format(walk.date)),
          ],
        ),
        title: Text("${walk.city} (${walk.entity})", overflow: TextOverflow.ellipsis),
        subtitle: Text(
            "${walk.contactLastName} ${walk.contactFirstName} : ${walk.contactPhoneNumber}"));
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
