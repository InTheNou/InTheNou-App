import 'package:flutter/material.dart';

class RoomView extends StatefulWidget {

  @override
  _RoomViewState createState() => new _RoomViewState();

}

class _RoomViewState extends State<RoomView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RoomView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("RoomView", style: Theme.of(context).textTheme.headline4,),
          ],
        ),
      ),
    );
  }
}