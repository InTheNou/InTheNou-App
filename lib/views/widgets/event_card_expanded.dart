import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/views/widgets/dismiss_button.dart';
import 'package:InTheNou/views/widgets/follow_button.dart';
import 'package:InTheNou/views/widgets/loading_image.dart';
import 'package:flutter/material.dart';

/// Widget to show Event results with a top image
///
/// {@category Widget}
class EventCardExpanded extends StatelessWidget {

  final Event _event;
  final FeedType _feedType;
  final bool interactionEnabled;
  EventCardExpanded(this._event, this._feedType, {this.interactionEnabled = true});

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
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Visibility(
                      visible: _event.image != null && _event.image.isNotEmpty,
                      child: LoadingImage(
                          imageURL: _event.image,
                          height: 150,
                          width: double.infinity),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                        ],
                      ),
                    ),
                    Visibility(
                      visible:  interactionEnabled &&
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
              )
            ],
          ),
        )
    );
  }

}