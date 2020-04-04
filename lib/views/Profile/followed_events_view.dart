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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FollowedEventsView"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => refreshFollowedAction(),
          ),
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody(){
    if(_userStore.isFollowedLoading){
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if(_userStore.followedEventError !=null){
        showErrorDialog(_userStore.followedEventError);
      }
      return  ListView.builder(
          itemCount: _userStore.followedEvents.length,
          itemBuilder: (context, index){
            Event _event = _userStore.followedEvents[index];
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
                                              unFollowEventAction
                                                (MapEntry(FeedType.Detail, _event
                                              )) :
                                              followEventAction
                                                (MapEntry(FeedType.Detail, _event
                                              ));
                                            refreshFollowedAction();
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
          });
    }
  }

  Future showErrorDialog(String errorText) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text(errorText),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                clearErrorAction(FeedType.PersonalFeed);
              },
            ),
          ],
        ),
      );
    });
  }
}