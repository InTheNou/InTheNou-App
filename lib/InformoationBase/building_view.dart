import 'package:flutter/material.dart';

class BuildingView extends StatefulWidget {

  @override
  _BuildingViewState createState() => new _BuildingViewState();

}

class _BuildingViewState extends State<BuildingView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BuildingView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("BuildingView", style: Theme.of(context).textTheme.headline4,),
          ],
        ),
      ),
    );
  }
}