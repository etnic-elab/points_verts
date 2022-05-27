import 'dart:async';

import 'package:flutter/material.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/models/address.dart';

import '../loading.dart';

const countryCodes = ['BE', 'FR', 'LU'];
const countryLabels = ['Belgique', 'France', 'Luxembourg'];

class SettingsHomeSelect extends StatefulWidget {
  const SettingsHomeSelect(this.setHomeCallback, this.removeHomeCallback,
      {this.sessionToken, Key? key})
      : super(key: key);

  final Function(AddressSuggestion) setHomeCallback;
  final Function removeHomeCallback;
  final String? sessionToken;

  @override
  _SettingsHomeSelectState createState() => _SettingsHomeSelectState();
}

class _SettingsHomeSelectState extends State<SettingsHomeSelect> {
  final MapInterface map = Environment.mapInterface;

  final _homeSearchController = TextEditingController();
  Timer? _debounce;
  int _countryIndex = 0;
  Future<List<AddressSuggestion>> _suggestions = Future.value([]);

  @override
  void initState() {
    super.initState();
    _homeSearchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _homeSearchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _suggestions = _homeSearchController.text.isEmpty
            ? Future.value([])
            : map.retrieveSuggestions(
                _homeSearchController.text, countryCodes[_countryIndex],
                sessionToken: widget.sessionToken);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  widget.removeHomeCallback();
                  _homeSearchController.removeListener(_onSearchChanged);
                  Navigator.of(context).pop();
                })
          ],
          title: const Text("Recherche du domicile"),
        ),
        body: _pageContent(context));
  }

  Widget _pageContent(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(
        title: const Text("Pays"),
        subtitle: Text(countryLabels[_countryIndex]),
        onTap: () => _countrySelection(context),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: TextField(
          controller: _homeSearchController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: "Adresse du domicile"),
        ),
      ),
      Expanded(child: _suggestionList())
    ]);
  }

  Widget _suggestionList() {
    return FutureBuilder(
        future: _suggestions,
        builder: (BuildContext context,
            AsyncSnapshot<List<AddressSuggestion>> snapshot) {
          if (snapshot.hasData) {
            List<AddressSuggestion> suggestions = snapshot.data!;
            return ListView.separated(
                itemCount: suggestions.length,
                separatorBuilder: (context, i) => const Divider(height: 0.5),
                itemBuilder: (context, i) {
                  AddressSuggestion suggestion = suggestions[i];
                  return ListTile(
                      title: Text(suggestion.name),
                      subtitle: Text(suggestion.description,
                          overflow: TextOverflow.ellipsis),
                      onTap: () {
                        widget.setHomeCallback(suggestion);
                        _homeSearchController.removeListener(_onSearchChanged);
                        Navigator.of(context).pop();
                      });
                });
          }
          if (snapshot.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.warning),
                Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(children: const [
                      Expanded(
                          child: Center(
                              child: Text(
                                  "Une erreur est survenue lors de la récupération des données. Merci de réessayer plus tard.",
                                  textAlign: TextAlign.center)))
                    ]))
              ],
            );
          }
          return const Loading();
        });
  }

  Future<void> _countrySelection(BuildContext context) async {
    int? index = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: const Text('Choix du pays'),
              children: generateOptions(context));
        });
    if (index != null) {
      setState(() => _countryIndex = index);
    }
  }

  static List<SimpleDialogOption> generateOptions(BuildContext context) {
    List<SimpleDialogOption> results = [];
    for (int i = 0; i < countryCodes.length; i++) {
      results.add(SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, i);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(countryLabels[i]),
          )));
    }
    return results;
  }
}
