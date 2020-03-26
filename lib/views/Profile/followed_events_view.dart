import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_store.dart';
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
    _userStore = listenToStore(userStoreToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FollowedEventsView"),
      ),
      body: ListView.builder(
          itemCount: _userStore.followedEvents.length,
          itemBuilder: (context, index){
            Event _event = _userStore.followedEvents[index];
            return Card(
                key: ValueKey(_event.UID),
                margin: EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () {
                    openEventDetail(MapEntry(FeedType.GeneralFeed, _event.UID));
                    Navigator.of(context).pushNamed(
                        '/eventdetail',
                        arguments: FeedType.GeneralFeed
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
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    ButtonTheme(
                                        minWidth: 120.0,
                                        child: OutlineButton(
                                          child: Text(_event.followed ?
                                          "UNFOLLOW":'FOLLOW'
                                          ),
                                          textColor: Theme.of(context).primaryColor,
                                          borderSide: BorderSide(
                                              color: Theme.of(context).primaryColor,
                                              width: _event.followed ? 1.5 : 0.0
                                          ),
                                          onPressed: () {
                                            _event.followed ?
                                            unFollowEventAction(_event) :
                                            followEventAction(_event);
                                            refreshFollowedEventsAction();
                                          },
                                        )
                                    )
                                  ]
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            );
          })
    );
  }
}