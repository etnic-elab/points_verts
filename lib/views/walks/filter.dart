import 'package:flutter/material.dart';
import 'package:points_verts/abstractions/company_data.dart';
import 'package:points_verts/abstractions/layout_extension.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/views/walks/sort_sheet.dart';
import 'package:points_verts/views/widgets/list_header.dart';

class FilterBar extends StatelessWidget {
  const FilterBar(this.sortSheet, {Key? key}) : super(key: key);

  final SortSheet sortSheet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            style: _buttonStyle,
            child: _buttonText(sortSheet.title, sortSheet.icon),
            onPressed: () => sortSheet.show(context),
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

class FilterFAB extends StatelessWidget {
  const FilterFAB(this.sortSheet, {Key? key}) : super(key: key);

  final SortSheet sortSheet;

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: 250,
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
              icon: Icon(sortSheet.icon),
              label: Text(sortSheet.title),
              onPressed: () => sortSheet.show(context),
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
                          widget.filter.cancelledWalks.layout.description!),
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
      .map((LayoutExtension layoutExtension) =>
          _PaddedChip(layoutExtension, updateValue))
      .toList();
  List<Widget> get _criterias => widget.filter.criterias
      .map((LayoutExtension layoutExtension) =>
          _PaddedChip(layoutExtension, updateValue))
      .toList();

  void updateValue(LayoutExtension layoutExtension, bool newValue) {
    layoutExtension.value = newValue;
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
  const _PaddedChip(this.layoutExtension, this.callback);

  final LayoutExtension layoutExtension;
  final Function(LayoutExtension, bool) callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: FilterChip(
        elevation: 6.0,
        avatar: layoutExtension.layout.icon != null
            ? Icon(
                layoutExtension.layout.icon,
                size: 15.0,
              )
            : null,
        label: Text(layoutExtension.layout.label!),
        selected: layoutExtension.value,
        onSelected: (newValue) {
          callback(layoutExtension, newValue);
        },
      ),
    );
  }
}
