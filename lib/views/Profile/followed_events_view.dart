import 'package:flutter/material.dart';

class FollowedEventsView extends StatefulWidget {

  @override
  _FollowedEventsViewState createState() => new _FollowedEventsViewState();

}

class _FollowedEventsViewState extends State<FollowedEventsView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FollowedEventsView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("FollowedEventsView", style: Theme
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