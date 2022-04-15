import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/models/news.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

Future showNews(BuildContext context, List<News> news, int initialPage) {
  return showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: 'news_dialog',
    context: context,
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Dialog(
            insetPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: CarouselWithIndicator(
                news.map((news) => _NewsImage(news)).toList(), initialPage)),
      );
    },
  );
}

class CarouselWithIndicator extends StatefulWidget {
  const CarouselWithIndicator(this.images, this.initialPage, {Key? key})
      : super(key: key);

  final List<Widget> images;
  final int initialPage;

  @override
  State<StatefulWidget> createState() => _CarouselWithIndicator();
}

class _CarouselWithIndicator extends State<CarouselWithIndicator> {
  int _current = 0;
  final Set<int> _viewed = {0};
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _viewed);
        return false;
      },
      child: SizedBox(
        height: min(MediaQuery.of(context).size.height * 0.92, 680),
        width: min(MediaQuery.of(context).size.width * 0.92, 1000),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CarouselSlider(
                items: widget.images,
                carouselController: _controller,
                options: CarouselOptions(
                    viewportFraction: 1,
                    initialPage: widget.initialPage,
                    enableInfiniteScroll: widget.images.length > 1,
                    autoPlay: widget.images.length > 1,
                    autoPlayInterval: const Duration(seconds: 15),
                    enlargeCenterPage: true,
                    disableCenter: true,
                    pageSnapping: true,
                    onPageChanged: (index, reason) => setState(() {
                          _current = index;
                          _viewed.add(index);
                        })),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.images.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              right: 0.0,
              top: 0.0,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  padding: const EdgeInsets.all(0),
                  onPressed: () => Navigator.pop(context, _viewed),
                  tooltip: 'Fermer la fenêtre',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsImage extends StatelessWidget {
  const _NewsImage(this.news, {Key? key}) : super(key: key);

  final News news;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          return CachedNetworkImage(
            imageUrl: constraints.maxWidth < 600
                ? news.imageUrlPortrait
                : news.imageUrlLandscape,
            imageBuilder: (context, imageProvider) {
              return Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: () => launchURL(news.url),
                    )),
              ]);
            },
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress)),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        }),
      ],
    );
  }
}
