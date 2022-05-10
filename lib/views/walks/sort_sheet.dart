import 'package:flutter/material.dart';
import 'package:points_verts/models/view_type.dart';
import 'package:points_verts/models/walk_sort.dart';

class SortSheet {
  final SortBy sortBy;
  final Future Function(SortBy) sortUpdate;
  final ViewType viewType;

  SortSheet(this.sortBy, this.sortUpdate, this.viewType);

  String get title {
    switch (viewType) {
      case ViewType.calendarList:
        return 'Trier';
      case ViewType.calendarMap:
        return 'Position';
      default:
        return 'Sort';
    }
  }

  IconData get icon {
    switch (viewType) {
      case ViewType.calendarList:
        return Icons.sort;
      case ViewType.calendarMap:
        return Icons.edit_location;
      default:
        return Icons.error;
    }
  }

  Map<SortBy, String> get choices {
    switch (viewType) {
      case ViewType.calendarList:
        return {
          SortBy.fromType(SortType.city): 'Ville : A à Z',
          SortBy.fromType(SortType.homePosition): 'Domicile : Les plus proches',
          SortBy.fromType(SortType.currentPosition):
              'Position actuelle : Les plus proches',
        };
      case ViewType.calendarMap:
        return {
          SortBy.fromType(SortType.city): 'Aucune',
          SortBy.fromType(SortType.homePosition): 'Domicile',
          SortBy.fromType(SortType.currentPosition): 'Position actuelle',
        };
      default:
        return {};
    }
  }

  Future<void> show(BuildContext context) async {
    SortBy? newValue = await showModalBottomSheet(
        elevation: 8.0,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        context: context,
        builder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor,
                      borderRadius: BorderRadius.circular(10)),
                ),
                ListTile(title: Text(title)),
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
            ));

    if (newValue != null && newValue != sortBy) sortUpdate(newValue);
  }
}
