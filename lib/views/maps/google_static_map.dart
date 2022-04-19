import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/services/assets.dart';

class GoogleStaticMap extends StatelessWidget {
  const GoogleStaticMap(this.url, this.onTap, {Key? key}) : super(key: key);

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
            fit: BoxFit.cover,
            imageUrl: url + snapshot.data!,
            imageBuilder: onTap == null
                ? null
                : (context, imageProvider) {
                    return Ink.image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      child: Stack(
                        children: [
                          const Positioned(
                            bottom: 15.0,
                            right: 10.0,
                            child: FloatingActionButton.small(
                              child: Icon(Icons.open_in_full),
                              onPressed: null,
                            ),
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
