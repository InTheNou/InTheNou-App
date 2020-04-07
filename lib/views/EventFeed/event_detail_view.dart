import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
import 'package:InTheNou/views/widgets/link_with_icon_widget.dart';
import 'package:InTheNou/views/widgets/multi_text_with_icon_widget.dart';
import 'package:InTheNou/views/widgets/text_with_icon_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class EventDetailView extends StatefulWidget {

  final int _initialEvent;

  EventDetailView(this._initialEvent);

  @override
  _EventDetailViewState createState() => new _EventDetailViewState();

}

class _EventDetailViewState extends State<EventDetailView>
    with flux.StoreWatcherMixin<EventDetailView>{
  EventFeedStore _eventFeedStore;
  Event _detailEvent;

  @override
  void initState() {
    _eventFeedStore = listenToStore(EventFeedStore.eventFeedToken);
    if(widget._initialEvent != null){
      openEventDetail(widget._initialEvent)
          .then((value) {
        _detailEvent = _eventFeedStore.eventDetail;
      });
    } else{
      _detailEvent = _eventFeedStore.eventDetail;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // After the user dismiss the event, the loading dialog is shown until
    // we get a confirmation from the backend
    if(_eventFeedStore.isFeedLoading(FeedType.Detail)){
      _showLoadingDialog();
    } else {
      _dismissLoadingDialog();
    }

    if(_eventFeedStore.detailNeedsToClose){
      WidgetsBinding.instance.addPostFrameCallback((_) async{
        _eventFeedStore.detailNeedsToClose = false;
        // Remove the Loading AlertDialog if it's showing
        Navigator.of(context).pop();
      });
    }
    if(_eventFeedStore.getError(FeedType.Detail) !=null){
      _showErrorDialog(_eventFeedStore.getError(FeedType.Detail));
    }
    if(_detailEvent == null){
      return Scaffold(
        appBar: AppBar(
          title: Text("Loading"),
        ),
        body: Center(
            child: Container(
              child: CircularProgressIndicator(),
            ),
        ),
      );
    }
    else{
      return Scaffold(
        body:NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: _detailEvent.image != null ?  250.0 : 0,
                  floating: false,
                  pinned: true,
                  title: Text(_detailEvent.title,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).canvasColor
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      collapseMode: CollapseMode.none,
                      background: Container(
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.1,0.3,0.5],
                              colors: <Color>[
                                primaryColor.shade900, primaryColor.shade300,
                                Colors.transparent
                              ]
                          ),
                        ),
                        child: FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          placeholder: "lib/assets/placeholder.png",
                          height: 120.0,
                          image: _detailEvent.image ?? "",
                        ),
                      )
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded (
                      child: Column(
                        children: <Widget>[
                          //
                          //Basic Info
                          Card(
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _detailEvent.title,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Theme.of(context).textTheme
                                            .headline5.fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.only(bottom:
                                    8.0)),
                                    TextWithIcon(
                                        _detailEvent.creator,
                                        Icon(Icons.account_circle)),
                                    LinkWithIconWidget(
                                        _detailEvent.room.building+" "+
                                            _detailEvent.room.code,
                                        Utils.buildGoogleMapsLink(_detailEvent
                                            .room.coordinates),
                                        Icon(Icons.location_on)),
                                    const Padding(padding: EdgeInsets.only(bottom: 4.0)),
                                    TextWithIcon(_detailEvent.getDurationString(),
                                        Icon(Icons.today)),
                                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                                    Text(
                                        _detailEvent.description,
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
                                                onPressed: () =>
                                                    _detailEvent.followed ?
                                                    _showDismissUnableDialog() :
                                                    _showDismissDialog(),
                                              )
                                          ),
                                          Padding(padding: EdgeInsets.only(
                                              left: 80.0)),
                                          ButtonTheme(
                                              minWidth: 120.0,
                                              child: OutlineButton(
                                                child: Text(_detailEvent.followed ?
                                                "UNFOLLOW":'FOLLOW'
                                                ),
                                                textColor: Theme.of(context).primaryColor,
                                                borderSide: BorderSide(
                                                    color: Theme.of(context).primaryColor,
                                                    width: _detailEvent.followed ? 1.5 : 0.0
                                                ),
                                                onPressed: () {
                                                  _detailEvent.followed ?
                                                  unFollowEventAction
                                                  (MapEntry(FeedType.Detail, _detailEvent
                                                  )) :
                                                  followEventAction
                                                  (MapEntry(FeedType.Detail, _detailEvent
                                                  ));
                                                },
                                              )
                                          )
                                        ]
                                    ),
                                  ],
                                )
                            ),
                          ),
                          //
                          // Links
                          Visibility(
                            visible: _detailEvent.websites.length>0,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,8.0),
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
                                        bottom: 4.0)),
                                    ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(0),
                                        itemCount: _detailEvent.websites.length,
                                        itemBuilder: (context, index) {
                                          Website website = _detailEvent
                                              .websites[index];
                                          return LinkWithIconWidget(
                                              website.description ?? website.URL,
                                              website.URL,
                                              Icon(Icons.language));
                                        }
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
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
                                        MultiTextWithIcon(
                                            "Default Notification:",
                                            _eventFeedStore
                                                .getDefaultNotification()
                                                .toString()+ " mins before",
                                            Icons.alarm_on),
                                        const Padding(padding: EdgeInsets.only(
                                            bottom: 8.0)),
                                        MultiTextWithIcon(
                                            "Smart Notification:",
                                            _eventFeedStore
                                                .getSmartNotification(),
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                                _detailEvent.tags.length,
                                                    (i) => Chip(
                                                    label: Text(
                                                        _detailEvent.tags[i].name
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
        ),
      );
    }
  }

  Future _showErrorDialog(String errorText) async {
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
                clearErrorAction(FeedType.Detail);
              },
            ),
          ],
        ),
      );
    });
  }

  Future _showLoadingDialog() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<void>(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true,
          builder: (context) {
            return AlertDialog(
              title: Text("Dismissing the Event"),
              content: Container(
                child: CircularProgressIndicator(),
                alignment: AlignmentDirectional.center,
                width: 100,
                height: 100,
              ),
            );
          }
      );
    });
  }

  Future _dismissLoadingDialog() async{
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      // Remove the Loading AlertDialog if it's showing
      Navigator.of(context).popUntil(ModalRoute.withName('/eventdetail'));
    });
  }

  void _showDismissDialog(){
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
                dismissEventAction(_detailEvent.UID);
                confirmDismissAction(FeedType.Detail);
              },
            )
          ],
        );
      }
    );
  }

  void _showDismissUnableDialog(){
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

