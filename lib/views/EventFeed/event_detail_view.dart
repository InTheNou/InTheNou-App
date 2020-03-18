import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_store.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:url_launcher/url_launcher.dart';

class EventDetailView extends StatefulWidget {

  final FeedType _feedType;

  EventDetailView(this._feedType);
  @override
  _EventDetailViewState createState() => new _EventDetailViewState();

}

class _EventDetailViewState extends State<EventDetailView>
    with flux.StoreWatcherMixin<EventDetailView>{
  EventFeedStore _eventFeedStore;
  Event detailEvent;

  @override
  void initState() {
    _eventFeedStore = listenToStore(EventFeedStore.eventFeedToken);
    detailEvent = _eventFeedStore.detailedEvent(widget._feedType);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(detailEvent.title,
        maxLines: 1,),
      ),
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded (
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Card(
                    key: ValueKey(0),
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
                                  detailEvent.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Theme.of(context).textTheme
                                        .headline5.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.only(bottom:
                                8.0)),
                                LinkWithIcon(
                                    detailEvent.room.code,
                                    buildGoogleMapsLink(detailEvent),
                                    Icons.location_on),
                                const Padding(padding: EdgeInsets.only(bottom: 4.0)),
                                TextWithIcon(detailEvent.getDurationString(),
                                    Icons.today),
                                const Padding(padding: EdgeInsets.only(
                                    bottom: 8.0)),
                                Text(
                                    detailEvent.description,
                                    style: Theme.of(context).textTheme.subtitle1
                                ),
                                const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ButtonTheme(
                                          minWidth: 120.0,
                                          child: OutlineButton(
                                            child: const Text('DISMISS'),
                                            textColor: Theme.of(context).accentColor,
                                            highlightedBorderColor: Theme.of(context).accentColor,
                                            onPressed: () {
                                              showDismissDialog(context);
                                            },
                                          )
                                      ),
                                      Padding(padding: EdgeInsets.only(
                                          left: 80.0)),
                                      ButtonTheme(
                                          minWidth: 120.0,
                                          child: OutlineButton(
                                            child: Text(detailEvent.followed ?
                                            "UNFOLLOW":'FOLLOW'
                                            ),
                                            textColor: Theme.of(context).primaryColor,
                                            borderSide: BorderSide(
                                                color: Theme.of(context).primaryColor,
                                                width: detailEvent.followed ? 1.5 : 0.0
                                            ),
                                            onPressed: () {
                                              print("i'm getting here");
                                              detailEvent.followed ?
                                              unFollowEventAction(detailEvent.UID) :
                                              followEventAction(detailEvent.UID);
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
                  ),
                  Card(
                    key: ValueKey(1),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0, left:
                      8.0, right: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Links",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: Theme.of(context).textTheme
                                  .body2.fontSize,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(
                              bottom: 8.0)),
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: detailEvent.websites.length,
                              itemBuilder: (context, index) {
                                return LinkWithIcon(
                                    detailEvent.websites[index].description,
                                    detailEvent.websites[index].URL,
                                    Icons.language);
                              }
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    key: ValueKey(2),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left:
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
                                  "Reminders",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Theme.of(context).textTheme
                                        .body2.fontSize,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.only(
                                    bottom: 8.0)),
                                //TODO: Join this with the settings
                                MultiTextWithIcon(
                                    "Default Notification:",
                                    "30mins before",
                                    Icons.alarm_on),
                                const Padding(padding: EdgeInsets.only(
                                    bottom: 8.0)),
                                MultiTextWithIcon(
                                    "Smart Notification:",
                                    "On",
                                    Icons.alarm_on),
                                const Padding(padding: EdgeInsets.only(
                                    bottom: 8.0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    key: ValueKey(3),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left:
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
                                  "Tags",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Theme.of(context).textTheme
                                        .body2.fontSize,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.only(
                                    bottom: 8.0)),
                                Wrap(
                                    alignment: WrapAlignment.start,
                                    direction: Axis.horizontal,
                                    spacing: 8.0,
                                    children: List<Widget>.generate(
                                        detailEvent.tags.length,
                                            (i) => Chip(
                                            label: Text(
                                                detailEvent.tags[i].name
                                            )
                                        )
                                    )
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ]
        ),
      )
    );
  }

  void showDismissDialog(BuildContext context){
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text("Dismissed an Event"),
          content: Text(
              "Are you sure you want to dismiss this Evet?\n\n"
                  "You will no longer see this event in your feeds",
              style: Theme.of(context).textTheme.subtitle1
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("UNDO"),
              textColor: Theme.of(context).primaryColor,
              onPressed: (){
                Navigator.of(context).pop();
              }
            ),
            FlatButton(
              child: Text("CONFIRM"),
              textColor: Theme.of(context).primaryColor,
              onPressed: (){
                Navigator.of(context).pop();
                dismissEventAction(detailEvent.UID);
                confirmDismissAction();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }
}

String buildGoogleMapsLink(Event event){
  String url = "http://maps.google.com/maps?daddr="
      + event.room.coordinates.lat.toString() +
      "," + event.room.coordinates.long.toString()+"&z=14";
  return url;
}

class TextWithIcon extends StatelessWidget{
  String _text;
  IconData _icon;

  TextWithIcon(this._text, this._icon);
  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
        const Padding(padding: EdgeInsets.only(bottom: 4.0)),
        Row(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(left: 8.0)),
            Icon(_icon),
            const Padding(padding: EdgeInsets.only(left: 16.0)),
            Text(
              _text,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.only(bottom: 4.0)),
      ],
    );
  }
}

class MultiTextWithIcon extends StatelessWidget{
  String _boldText;
  String _normalText;
  IconData _icon;

  MultiTextWithIcon(this._normalText, this._boldText, this._icon);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Padding(padding: EdgeInsets.only(left: 8.0)),
        Icon(_icon),
        const Padding(padding: EdgeInsets.only(left: 16.0)),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.subtitle1,
            children: <TextSpan>[
              TextSpan(text: _normalText),
              TextSpan(text: "\t\t\t"),
              TextSpan(text: _boldText, style: TextStyle(
                  fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }
}

class LinkWithIcon extends StatelessWidget{
  String _description;
  String _URL;
  IconData _icon;

  LinkWithIcon(this._description, this._URL, this._icon);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(padding: EdgeInsets.only(bottom: 4.0)),
        Row(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(left: 8.0)),
            Icon(
                _icon),
            const Padding(padding: EdgeInsets.only(left: 16.0)),
            RichText(
              text: TextSpan(
                text: _description,
                style: new TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () { _launchURL(_URL);
                  },
              ),
            )
          ],
        ),
        const Padding(padding: EdgeInsets.only(bottom: 4.0)),
      ],
    );
  }
  _launchURL(String URL) async {
    if (await canLaunch(URL)) {
      await launch(URL);
    } else {
      throw 'Could not launch $URL';
    }
  }
}