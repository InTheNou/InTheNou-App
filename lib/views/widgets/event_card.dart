import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {

  final Event _event;
  final FeedType _feedType;
  EventCard(this._event, this._feedType);

  @override
  Widget build(BuildContext context) {
    return Card(
        key: ValueKey(_event.UID),
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
                              OutlineButton(
                                child: Text('DISMISS'),
                                textColor: Theme.of(context).accentColor,
                                highlightedBorderColor: Theme.of(context).accentColor,
                                onPressed: () {
                                  _event.followed ?
                                  _showDismissUnableDialog(context) :
                                  _dismissEvent(_event, context);
                                },
                              ),
                              Padding(padding: EdgeInsets.only(left: 30.0)),
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
                                        (MapEntry(_feedType, _event)):
                                      followEventAction
                                        (MapEntry(_feedType, _event));
                                    },
                                  )
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
  }

  /// Creates a Snackbar to undo the Dismissal of [event].
  ///
  /// Calls [dismissEventAction] with the [Event._UID] of [event] to modify
  /// the list of events in th feed locally. Also shows the [SnackBar]
  /// [_undoSnackbar] that calls the backend to do the proper dismissal of
  /// th event if the snackbar action is not used.
  void _dismissEvent(Event event, BuildContext context){
    Scaffold.of(context).showSnackBar(_undoSnackbar).closed
        .then((SnackBarClosedReason reason) {
      if (reason == SnackBarClosedReason.dismiss ||
          reason == SnackBarClosedReason.hide ||
          reason == SnackBarClosedReason.remove ||
          reason == SnackBarClosedReason.timeout){
        confirmDismissAction(_feedType);
      }
    });

    dismissEventAction(event.UID);
  }

  /// Creates a [SnackBar] that undoes Dismissing an event.
  ///
  /// Gives the user the option to bring back the Event they just dismissed
  /// by calling [undoDismissAction] and add the event back to the list
  /// locally.
  final _undoSnackbar = SnackBar(
    content: Text('Undo Dismiss'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        undoDismissAction();
      },
    ),
  );

  /// Creates an [AlertDialog] to prevent the uer from dismissing a followed
  /// event.
  ///
  ///
  void _showDismissUnableDialog(BuildContext context){
    showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text("Unable to Dismiss"),
            content: Text(
                "Please unfollow the Event before dismissing it.",
                style: Theme.of(context).textTheme.subtitle1
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text("OK"),
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () => Navigator.of(context).pop()
              )
            ],
          );
        }
    );
  }

}