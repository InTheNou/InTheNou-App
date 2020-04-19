import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

class LoadingImage extends StatelessWidget {

  final String imageURL;
  final double width;
  final double height;

  LoadingImage({
    @required this.imageURL,
    @required this.width,
    @required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: CachedNetworkImage(
        imageUrl: (imageURL !=null && isURL(imageURL)) ? imageURL : "",
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Image.asset("lib/assets/placeholder.png", fit: BoxFit.fill),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            Align(
                alignment: Alignment.bottomCenter,
                child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    value: downloadProgress.progress)
            ),
      ),
    );
  }
}