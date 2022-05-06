import 'dart:math';

import 'package:flutter/material.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/walks/filter.dart';
import 'package:points_verts/views/walks/sort_sheet.dart';
import 'package:points_verts/views/widgets/loading.dart';
import 'package:points_verts/views/walks/tile.dart';

class CalendarListView extends StatelessWidget {
  const CalendarListView(
      {required this.appBar,
      required this.walks,
      required this.sortSheet,
      required this.refreshData,
      required this.scrollController,
      required this.searching,
      required this.filterBarHidden,
      required this.results,
      Key? key})
      : super(key: key);

  final Widget appBar;
  final List<Walk> walks;
  final SortSheet sortSheet;
  final Future Function() refreshData;
  final ScrollController scrollController;
  final Future? searching;
  final bool filterBarHidden;
  final int results;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        RefreshIndicator(
          onRefresh: refreshData,
          displacement: 15.0,
          edgeOffset: 150.0,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            semanticChildCount: walks.length,
            controller: scrollController,
            slivers: [appBar, ...slivers],
          ),
        ),
        ...stackables,
      ],
    );
  }

  List<Widget> get slivers {
    List<Widget> slivers = [];
    if (searching == null) {
      slivers = [
        SliverToBoxAdapter(
          child: FilterBar(sortSheet),
        ),
        _SliverList(walks),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100))
      ];
    } else {
      slivers = [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: LoadingText('Recherche en cours...'),
        )
      ];
    }

    return slivers;
  }

  List<Widget> get stackables {
    List<Widget> stackable = [];
    if (searching == null) {
      stackable = [
        AnimatedBuilder(
          animation: scrollController,
          child: FilterFAB(sortSheet),
          builder: (BuildContext context, Widget? child) {
            double _bottom = -55.0;
            if (scrollController.position.hasContentDimensions) {
              _bottom =
                  min(scrollController.position.extentBefore - 55.0, 15.0);
            }
            return Positioned(child: child!, bottom: _bottom);
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 310),
            offset: filterBarHidden == false ? Offset.zero : const Offset(0, 3),
            curve: Curves.decelerate,
            child: _ResultsBar(results),
          ),
        )
      ];
    }

    return stackable;
  }
}

class _SliverList extends StatelessWidget {
  const _SliverList(this.walks, {Key? key}) : super(key: key);

  final List<Walk> walks;

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        final int itemIndex = index ~/ 2;
        if (index.isEven) return WalkTile(walks[itemIndex], TileType.calendar);

        return const Divider(
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

class _ResultsBar extends StatelessWidget {
  const _ResultsBar(this.results, {Key? key}) : super(key: key);

  final int? results;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Center(
          child: Text(
            label,
            textScaleFactor: 1.3,
          ),
        ),
      ),
    );
  }

  String get label =>
      results != null ? '$results résultat' + (results! > 1 ? 's' : '') : '';
}

// class _List extends StatelessWidget {
//   const _List(this.walks, {Key? key}) : super(key: key);

//   final List<Walk> walks;

//   @override
//   Widget build(BuildContext context) {
//     if (walks.isEmpty) {
//       return const Center(child: Text("Aucun résultat"));
//     }

//     return ListView.separated(
//       separatorBuilder: ((context, index) => const Divider(
//             height: 50,
//             indent: 10,
//             endIndent: 10,
//             thickness: 1,
//           )),
//       itemBuilder: (context, i) {
//         return WalkTile(walks[i], TileType.calendar);
//       },
//       itemCount: walks.length,
//     );
//   }
// }
