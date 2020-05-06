import 'package:flutter/material.dart';

class LoadingBodyWidget extends StatelessWidget {

  LoadingBodyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100,
        width: 100,
        child: CircularProgressIndicator(),
      ),
    );
  }

}