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
      constraints: BoxConstraints.expand(width: width, height: height),
      child: buildImage()
    );
  }

  Widget buildImage(){
    if(imageURL == null || imageURL.isEmpty || !isURL(imageURL)){
      return Image.asset("lib/assets/placeholder.png", fit: BoxFit.cover);
    }
    else {
      return CachedNetworkImage(
        imageUrl:imageURL,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Image.asset("lib/assets/placeholder.png", fit: BoxFit.cover),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            Align(
                alignment: Alignment.bottomCenter,
                child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    value: downloadProgress.progress)
            ),
      );
    }

  }
}