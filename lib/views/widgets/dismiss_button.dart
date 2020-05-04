import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
import 'package:flutter/material.dart';

/// Widget used for Dismissing Events
///
/// {@category Widget}
class DismissButton extends StatelessWidget {

  final DialogService _dialogService = DialogService();
  final Event _event;
  final FeedType _feedType;
  DismissButton(this._event, this._feedType):
        super(key: ValueKey(_event.UID));

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return ConstrainedBox (
          constraints: BoxConstraints(
            minWidth: 110
          ),
          child: FlatButton(
            child: const Text('DISMISS'),
            textColor: Theme.of(context).errorColor,
            onPressed: () {
              if(!_event.followed){
                if(_feedType == FeedType.Detail){
                  _showDismissDialog(_event);
                } else {
                  dismissEventAction(_event);
                  _showUndoSnackbar(_event, context);
                }
              } else {
                dismissEventAction(_event);
              }
            },
          ),
        );
      },
    );
  }
  void _showDismissDialog(Event eventDetail){
    _dialogService.showDialog(
        type: DialogType.ImportantAlert,
        title: "Dismissing an Event",
        description: "Are you sure you want to dismiss this Event?\n"
            "You will no longer see this event in your feeds.",
        primaryButtonTitle: "DISMISS"
    ).then((result) async{
      if(result.result){
        await dismissEventAction(eventDetail);
        confirmDismissAction(FeedType.Detail);
      }
    });
  }

  /// Creates a Snackbar to undo the Dismissal of [event].
  ///
  /// Shows the [SnackBar] instance in [_undoSnackbar] that calls the
  /// backend to do the proper dismissal of
  /// th event if the snackbar action is not used.
  void _showUndoSnackbar(Event event, BuildContext context){
    Scaffold.of(context).showSnackBar(_undoSnackbar).closed
        .then((SnackBarClosedReason reason) {
      if (reason == SnackBarClosedReason.dismiss ||
          reason == SnackBarClosedReason.hide ||
          reason == SnackBarClosedReason.remove ||
          reason == SnackBarClosedReason.timeout){
        confirmDismissAction(_feedType);
      }
    });
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
}