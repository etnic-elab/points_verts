// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:points_verts/models/walk.dart';
// import 'package:points_verts/models/walk_filter.dart';
// import 'package:points_verts/views/walks/calendar_list_view.dart';

// class WalkList extends StatelessWidget {
//   const WalkList(this.walks, this.filter, this.filterUpdate, this.refreshData,
//       {Key? key})
//       : super(key: key);

//   final List<DateTime> dates;
//   final List<Walk> walks;
//   final WalkFilter filter;
//   final Future<int?> Function(WalkFilter) filterUpdate;
//   final Future Function() refreshData;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const Drawer(),
//       endDrawer: FilterDrawer(filter, walks.length, filterUpdate),
//       body: Builder(builder: (context) {
//         return Stack(
//           alignment: Alignment.center,
//           children: [
//             RefreshIndicator(
//               onRefresh: refreshData,
//               displacement: 15.0,
//               edgeOffset: 150.0,
//               child: CustomScrollView(
//                 semanticChildCount: walks.length,
//                 controller: scrollController,
//                 slivers: [
//                   SliverAppBar(
//                     elevation: 6.0,
//                     pinned: true,
//                     leading: Opacity(
//                       opacity: 0.8,
//                       child: IconButton(
//                         icon: const Icon(Icons.menu),
//                         splashRadius: Material.defaultSplashRadius / 1.5,
//                         tooltip: 'Ouvrir le menu de navigation',
//                         onPressed: () => Scaffold.of(context).openDrawer(),
//                       ),
//                     ),
//                     actions: [
//                       IconButton(
//                         icon: const Icon(Icons.calendar_today),
//                         splashRadius: Material.defaultSplashRadius / 1.5,
//                         tooltip: 'Choisir la date',
//                         onPressed: () => dateUpdate(dates),
//                       ),
//                       IconButton(
//                         splashRadius: Material.defaultSplashRadius / 1.5,
//                         icon: Icon(
//                           _viewType == _ViewType.list ? Icons.map : Icons.list,
//                         ),
//                         tooltip: _viewType == _ViewType.list
//                             ? 'Voir sur la carte'
//                             : 'Voir en liste',
//                         onPressed: () {
//                           setState(() {
//                             _viewType = _viewType == _ViewType.list
//                                 ? _ViewType.map
//                                 : _ViewType.list;
//                           });
//                         },
//                       ),
//                     ],
//                     title: SizedBox(
//                       width: double.infinity,
//                       child: GestureDetector(
//                         child: Opacity(
//                           opacity: 0.8,
//                           child: Tooltip(
//                               child: Text(
//                                   DateFormat.yMMMEd("fr_BE")
//                                       .format(filter.date!),
//                                   overflow: TextOverflow.ellipsis),
//                               message: 'La date sélectionnée'),
//                         ),
//                         onTap: () => dateUpdate(dates),
//                       ),
//                     ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: FilterBar(showSort),
//                   ),
//                   _viewType == _ViewType.list
//                       ? WalkResultSliverList(walks)
//                       : SliverFillRemaining(
//                           hasScrollBody: false,
//                           child: CalendarMapView(walks, _position, _place,
//                               _selectedWalk, onWalkSelect, onTapMap),
//                         ),
//                   if (_viewType == _ViewType.list)
//                     const SliverPadding(padding: EdgeInsets.only(bottom: 100))
//                 ],
//               ),
//             ),
//             if (_viewType == _ViewType.list)
//               AnimatedBuilder(
//                 animation: scrollController,
//                 child: FilterFAB(showSort),
//                 builder: (BuildContext context, Widget? child) {
//                   double _bottom = -55.0;
//                   if (scrollController.position.hasContentDimensions) {
//                     _bottom = math.min(
//                         scrollController.position.extentBefore - 55.0, 15.0);
//                   }
//                   return Positioned(child: child!, bottom: _bottom);
//                 },
//               ),
//             if (_viewType == _ViewType.list)
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: AnimatedSlide(
//                   duration: const Duration(milliseconds: 310),
//                   offset: _results != null && _filterBarHidden == false
//                       ? Offset.zero
//                       : const Offset(0, 3),
//                   curve: Curves.decelerate,
//                   child: _ResultsBar(_results),
//                 ),
//               ),
//             if (_viewType == _ViewType.map && _selectedWalk != null)
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: WalkTile(_selectedWalk!, TileType.map),
//               ),
//           ],
//         );
//       }),
//     );
//   }
// }
