import 'dart:math';

import 'package:flutter/material.dart';
import 'package:points_verts/models/walk.dart';

import 'walk_tile.dart';

class WalkResultsList extends StatelessWidget {
  const WalkResultsList(this.walks, {Key? key}) : super(key: key);

  final List<Walk> walks;

  @override
  Widget build(BuildContext context) {
    if (walks.isEmpty) {
      return const Center(child: Text("Aucun résultat"));
    }

    return ListView.separated(
      separatorBuilder: ((context, index) => const Divider(
            height: 50,
            indent: 10,
            endIndent: 10,
            thickness: 1,
          )),
      itemBuilder: (context, i) {
        return WalkTile(walks[i], TileType.calendar);
      },
      itemCount: walks.length,
    );
  }
}

class WalkResultSliverList extends StatelessWidget {
  const WalkResultSliverList(this.walks, {Key? key}) : super(key: key);

  final List<Walk> walks;

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        final int itemIndex = index ~/ 2;
        if (index.isEven) return WalkTile(walks[itemIndex], TileType.calendar);

        return const Divider(
          height: 50,
          indent: 10,
          endIndent: 10,
          thickness: 1,
        );
      },
      semanticIndexCallback: (Widget widget, int localIndex) {
        if (localIndex.isEven) {
          return localIndex ~/ 2;
        }
        return null;
      },
      childCount: max(0, walks.length * 2 - 1),
    ));
  }
}
