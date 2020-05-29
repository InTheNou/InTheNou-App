import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/views/widgets/dismiss_button.dart';
import 'package:InTheNou/views/widgets/follow_button.dart';
import 'package:InTheNou/views/widgets/loading_image.dart';
import 'package:flutter/material.dart';

/// Widget to show Event results with a side image
///
/// {@category Widget}
class EventCardImage extends StatelessWidget {

  final Event _event;
  final FeedType _feedType;
  final bool interactionEnabled;
  EventCardImage(this._event, this._feedType, {this.interactionEnabled = true});

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
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: _event.image != null && _event.image.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0,
                          left: 8.0, right: 0.0),
                      child: LoadingImage(
                          imageURL: _event.image,
                          height: 120,
                          width: 120),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0,
                          left: 16.0, right: 16.0),
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
                          const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                          Text(
                              _event.startDateTime.isBefore(DateTime.now()) ?
                                _event.getEndTimeString() :
                                _event.getDurationString(),
                              style: Theme.of(context).textTheme.bodyText1.copyWith(
                                  fontWeight: FontWeight.w400
                              )
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 4.0)),
                          Text(
                              _event.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle2
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: interactionEnabled &&
                    _event.status == "active" &&
                    !_event.dismissed &&
                    _event.endDateTime.isAfter(DateTime.now()),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      DismissButton(_event, _feedType),
                      FollowButton(_event, _feedType),
                    ]
                ),
              ),
            ],
          ),
        )
    );
  }

}