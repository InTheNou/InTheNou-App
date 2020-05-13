import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';

/// Widget used for Canceling Events or showing Events are canceled
///
/// {@category Widget}
class CancelButton extends StatelessWidget {

  final Event _event;
  CancelButton(this._event);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return ConstrainedBox (
          constraints: BoxConstraints(
              minWidth: 150
          ),
          child: FlatButton(
              child: _event.status == "active" ?
              Text("CANCEL") : Text("CANCELED"),
              textColor: Colors.white,
              color: Theme.of(context).errorColor,
              disabledColor: Theme.of(context).brightness == Brightness.dark ?
                Colors.grey[700] : Colors.grey[200],
              onPressed: _event.status == "deleted" ?
              null : () => cancelEventAction(_event)
          ),
        );
      },
    );
  }

}