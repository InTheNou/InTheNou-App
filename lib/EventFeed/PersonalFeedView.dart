import 'package:InTheNou/EventFeed/EventStore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

const String PERSONAL_FGEED = "Personal Feed";

class PersonalFeedView extends StatefulWidget{

  @override
  PersonalFeedViewState createState() => PersonalFeedViewState();
}

class PersonalFeedViewState extends State with flux.StoreWatcherMixin{
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
          title: Text(PERSONAL_FGEED),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Text(PERSONAL_FGEED,style: Theme.of(context).textTheme.headline4,
                ),
            ],
          ),
        ),
      floatingActionButton: new Visibility(
        visible: false,
        child: new FloatingActionButton(
          onPressed: test,
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ),
      ),
    );
  }
  void test(){}

}