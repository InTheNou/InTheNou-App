import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {

  final Event _event;
  final FeedType _feedType;
  FollowButton(this._event, this._feedType);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
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
            (MapEntry(_feedType, _event)):
          followEventAction
            (MapEntry(_feedType, _event));
        },
      ),
    );
  }

}