import 'package:flutter/material.dart';

class EventCreationView extends StatefulWidget {

  @override
  _EventCreationViewState createState() => new _EventCreationViewState();

}

class _EventCreationViewState extends State<EventCreationView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EventCreationView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("EventCreationView", style: Theme.of(context).textTheme.headline4,),
          ],
        ),
      ),
    );
  }
}