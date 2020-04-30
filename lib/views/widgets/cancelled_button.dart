import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';

class CancelledButton extends StatelessWidget {

  final Event _event;
  CancelledButton(this._event);

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
              Text("CANCEL") : Text("CANCELLED"),
              textColor: Theme.of(context).canvasColor,
              color: Theme.of(context).errorColor,
              disabledColor: Colors.grey[200],
              onPressed: _event.status == "deleted" ?
              null : () => cancelEventAction(_event)
          ),
        );
      },
    );
  }

}