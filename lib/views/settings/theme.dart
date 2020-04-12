import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tile_icon.dart';

class ThemeChoice extends StatelessWidget {
  ThemeChoice(this.current, this.callback);

  final String current;
  final Function(String) callback;

  String _defineThemeSubtitle() {
    if (current == "light") {
      return "Clair";
    } else if (current == "dark") {
      return "Sombre";
    } else {
      return "Automatique";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: TileIcon(Icon(Icons.palette)),
      title: Text('Thème'),
      subtitle: Text(_defineThemeSubtitle()),
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: EdgeInsets.only(top: 12),
              title: Text("Thème"),
              content: SingleChildScrollView(child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Divider(),
                      ListTile(
                          leading: Icon(Icons.info),
                          title: Text(
                              "Tout changement de thème nécessite un redémarrage de l'application.",
                              style: Theme.of(context).textTheme.caption)),
                      Divider(),
                      RadioListTile(
                        title: Text("Automatique"),
                        subtitle: Text("Laisse le système décider"),
                        value: null,
                        groupValue: current,
                        onChanged: (String value) {
                          callback(value);
                          Navigator.of(context).pop();
                        },
                      ),
                      RadioListTile(
                        title: Text("Clair"),
                        subtitle: Text("Force le mode clair"),
                        value: "light",
                        groupValue: current,
                        onChanged: (String value) {
                          callback(value);
                          Navigator.of(context).pop();
                        },
                      ),
                      RadioListTile(
                        title: Text("Sombre"),
                        subtitle: Text("Force le mode sombre"),
                        value: "dark",
                        groupValue: current,
                        onChanged: (String value) {
                          callback(value);
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              )),
              actions: [
                FlatButton(
                  child: Text('ANNULER'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
