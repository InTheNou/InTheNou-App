import 'package:flutter/material.dart';

class CreatedEventsView extends StatefulWidget {

  @override
  _CreatedEventsViewState createState() => new _CreatedEventsViewState();

}

class _CreatedEventsViewState extends State<CreatedEventsView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CreatedEventsView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("CreatedEventsView", style: Theme
                .of(context)
                .textTheme
                .headline4,
            ),
          ],
        ),
      ),
    );
  }
}