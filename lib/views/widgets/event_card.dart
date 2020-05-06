import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/views/widgets/dismiss_button.dart';
import 'package:InTheNou/views/widgets/follow_button.dart';
import 'package:flutter/material.dart';


/// Widget used for showing Event Results without images
///
/// {@category Widget}
class EventCard extends StatelessWidget {

  final Event _event;
  final FeedType _feedType;
  final bool interactionEnabled;
  EventCard(this._event, this._feedType, {this.interactionEnabled = true});

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
                        style: Theme.of(context).textTheme.headline6.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark ?
                            Theme.of(context).primaryColorLight :
                            Theme.of(context).primaryColor,
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
                        visible: interactionEnabled &&
                            _event.status == "active" &&
                            !_event.dismissed &&
                            _event.endDateTime.isAfter(DateTime.now()),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              DismissButton(_event, _feedType),
                              Padding(padding: EdgeInsets.only(left: 30.0)),
                              FollowButton(_event, _feedType),
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

}