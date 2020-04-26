import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


class FollowedEventsView extends StatefulWidget {

  @override
  _FollowedEventsViewState createState() => new _FollowedEventsViewState();

}

class _FollowedEventsViewState extends State<FollowedEventsView>
  with flux.StoreWatcherMixin<FollowedEventsView>{

  UserStore _userStore;

  @override
  void initState() {
    super.initState();
    _userStore = listenToStore(UserStore.userStoreToken);
    refreshFollowedAction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Followed Events"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => refreshFollowedAction(),
          ),
        ],
      ),
      body:  FutureBuilder(
        future: _userStore.followedEvents,
        builder: (BuildContext context,
            AsyncSnapshot<List<Event>> followedEvents) {
          if(followedEvents.hasError){
            return _buildErrorWidget(followedEvents.error);
          } else if (followedEvents.hasData){
            return _buildResultsWidget(followedEvents.data);
          } else {
            return _buildLoadingWidget();
          }
        },
      )
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(error,
                style: Theme.of(context).textTheme.headline5
              ),
            ),
          ],
        )
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 100,
                height: 100,
                child: CircularProgressIndicator()),
          ],
        )
    );
  }

  Widget _buildResultsWidget(List<Event> followedEvents) {
    return ListView.builder(
        itemCount: followedEvents.length,
        itemBuilder: (context, index){
          Event _event = followedEvents[index];
          return Card(
              key: ValueKey(_event.UID),
              margin: EdgeInsets.only(top: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                      '/eventdetail',
                      arguments: _event.UID
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left:
                  8.0, right: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 4.0)),
                            Text(
                                _event.getDurationString(),
                                style: Theme.of(context).textTheme.bodyText1
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                            Text(
                                _event.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.subtitle2
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                            Visibility(
                              visible: _event.status == "active",
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 110,
                                      child: FlatButton(
                                        child: Text(_event.followed ?
                                        "FOLLOWING":'FOLLOW'
                                        ),
                                        textColor: _event.followed ?
                                        Theme.of(context).cardColor :
                                        Theme.of(context).primaryColor ,
                                        color: _event.followed ?
                                        Theme.of(context).primaryColor :
                                        Theme.of(context).cardColor,
                                        onPressed: () {
                                          _event.followed ?
                                          unFollowEventAction
                                            (MapEntry(FeedType.Detail, _event)):
                                          followEventAction
                                            (MapEntry(FeedType.Detail, _event));
                                        },
                                      ),
                                    )
                                  ]
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          );
        });
  }
}