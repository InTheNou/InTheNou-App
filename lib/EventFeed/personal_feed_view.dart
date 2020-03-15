import 'package:InTheNou/EventFeed/event_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

const String PERSONAL_FGEED = "Personal Feed";

class PersonalFeedView extends StatefulWidget{

  @override
  _PersonalFeedViewState createState() => _PersonalFeedViewState();
}

class _PersonalFeedViewState extends State with flux.StoreWatcherMixin{
  EventFeedStore _eventFeedStore;

  @override
  void initState() {
    super.initState();

    _eventFeedStore = listenToStore(eventFeedToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(PERSONAL_FGEED),
        ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(PERSONAL_FGEED,style: Theme.of(context).textTheme.headline4),
            RaisedButton(
              child: Text('View Details'),
              onPressed: () {
                Navigator.of(context).pushNamed('/eventdetail');
              },
            )
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