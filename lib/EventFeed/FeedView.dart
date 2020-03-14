import 'package:InTheNou/EventFeed/EventStore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

const String GENERAL_FEED = "General Feed";

class GeneralFeedView extends StatefulWidget{

  @override
  GeneralFeedState createState() => GeneralFeedState();
}

class GeneralFeedState extends State with flux.StoreWatcherMixin{
  EventFeedStore eventFeedStore;

  @override
  void initState() {
    super.initState();

    eventFeedStore = listenToStore(eventFeedToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(GENERAL_FEED),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(GENERAL_FEED,style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }

}