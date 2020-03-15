import 'package:flutter/material.dart';

class EventDetailView extends StatefulWidget {

  @override
  _EventDetailViewState createState() => new _EventDetailViewState();

}

class _EventDetailViewState extends State<EventDetailView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DetailView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Details",style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}