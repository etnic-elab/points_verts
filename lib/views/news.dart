import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/models/news.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

Future showNewsDialog(BuildContext context, List<News> news) {
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
            child: _Carousel(news)),
      );
    },
  );
}

class _Carousel extends StatefulWidget {
  const _Carousel(this.news, {Key? key}) : super(key: key);

  final List<News> news;

  @override
  State<StatefulWidget> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  int _current = 0;
  late final List<Widget> images;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    images = widget.news.map((news) => _Image(news)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: min(MediaQuery.of(context).size.height * 0.92, 680),
      width: min(MediaQuery.of(context).size.width * 0.92, 1000),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CarouselSlider(
              items: images,
              carouselController: _controller,
              options: CarouselOptions(
                  viewportFraction: 1,
                  enableInfiniteScroll: images.length > 1,
                  autoPlay: images.length > 1,
                  autoPlayInterval: const Duration(seconds: 15),
                  enlargeCenterPage: true,
                  disableCenter: true,
                  pageSnapping: true,
                  onPageChanged: (index, _) =>
                      setState(() => _current = index)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: images.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
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
                onPressed: () => Navigator.pop(context),
                tooltip: 'Fermer la fenêtre',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image(this.news, {Key? key}) : super(key: key);

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
