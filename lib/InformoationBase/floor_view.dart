import 'package:flutter/material.dart';

class FloorView extends StatefulWidget {

  @override
  _FloorViewState createState() => new _FloorViewState();

}

class _FloorViewState extends State<FloorView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FloorView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("FloorView", style: Theme.of(context).textTheme.headline4,),
          ],
        ),
      ),
    );
  }
}