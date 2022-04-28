import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/services/assets.dart';

class GoogleStaticImage extends StatelessWidget {
  const GoogleStaticImage(this.url, this.onTap, {Key? key}) : super(key: key);

  final String url;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Assets.asset
          .string(Theme.of(context).brightness, Assets.googleMapStaticStyle),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          return CachedNetworkImage(
            imageUrl: url + snapshot.data!,
            imageBuilder: onTap == null
                ? null
                : (context, imageProvider) {
                    return Ink.image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10, bottom: 15),
                                child: FloatingActionButton.small(
                                  child: const Icon(Icons.open_in_full),
                                  onPressed: () {},
                                )),
                          ),
                          InkWell(onTap: () => onTap!())
                        ],
                      ),
                    );
                  },
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress)),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
