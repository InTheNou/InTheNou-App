import 'package:flutter/material.dart';

class LoadingScaffoldView extends StatelessWidget {

  LoadingScaffoldView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loading"),
      ),
      body: Center(
        child: Container(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

}