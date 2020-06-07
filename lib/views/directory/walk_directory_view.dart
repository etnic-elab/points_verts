import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/views/app_drawer.dart';
import 'package:points_verts/views/loading.dart';
import '../../models/walk.dart';
import '../walks/walk_details_view.dart';

class WalkDirectoryView extends StatefulWidget {
  @override
  _WalkDirectoryViewState createState() => _WalkDirectoryViewState();
}

class _WalkDirectoryViewState extends State<WalkDirectoryView> {
  final Future<List<Walk>> walks = DBProvider.db.getSortedWalks();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Annuaire"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {  }, )
        ],
      ),
      body: FutureBuilder(
        future: walks,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            DateFormat fullDate = DateFormat("dd/MM/yy", "fr_BE");
            return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                Walk walk = snapshot.data[index];
                return ListTile(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WalkDetailsView(walk))),
                    title: Text("${walk.city} (${walk.entity})"),
                    subtitle: Text(
                        "${fullDate.format(walk.date)} ${walk.type} - ${walk.contactLastName} ${walk.contactFirstName} : ${walk.contactPhoneNumber}"));
              },
              itemCount: snapshot.data.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            );
          } else {
            return Loading();
          }
        },
      ),
    );
  }
}
