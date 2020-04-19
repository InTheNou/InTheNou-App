import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
import 'package:InTheNou/views/widgets/link_with_icon_widget.dart';
import 'package:InTheNou/views/widgets/loading_image.dart';
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
  DialogService _dialogService = DialogService();

  @override
  void initState() {
    _eventFeedStore = listenToStore(EventFeedStore.eventFeedToken);
    if(widget._initialEvent != null){
      openEventDetail(widget._initialEvent);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _eventFeedStore.eventDetail,
      builder: (BuildContext context, AsyncSnapshot<Event> eventDetail) {
        if(eventDetail.hasData){
          return _buildBody(eventDetail.data);
        } else if(eventDetail.hasError){
          return _buildError(eventDetail.error);
        }
        return _buildLoading();
      },
    );
  }

  Widget _buildBody(Event eventDetail){
    _eventFeedStore.detailNeedsToClose.then((value){
      if(value){
       WidgetsBinding.instance.addPostFrameCallback((_) async{
         _eventFeedStore.detailNeedsToClose = Future.value(false);
         // Remove the Loading AlertDialog if it's showing
         Navigator.of(context).popUntil(ModalRoute.withName('/home'));
       });
     }
    });
    return Scaffold(
      body:NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: eventDetail.image != null ?  250.0 : 0,
                floating: false,
                pinned: true,
                title: Text(eventDetail.title,
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
                            stops: [0.1,0.25,0.4],
                            colors: <Color>[
                              Color.fromARGB(124, 0, 0, 0),
                              Color.fromARGB(77, 0, 0, 0),
                              Colors.transparent
                            ]
                        ),
                      ),
                      child: LoadingImage(
                        imageURL: eventDetail.image,
                        width: null,
                        height: null,
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
                                    eventDetail.title,
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
                                      eventDetail.creator,
                                      Icon(Icons.account_circle)),
                                  LinkWithIconWidget(
                                      eventDetail.room.building+" "+
                                          eventDetail.room.code,
                                      Utils.buildGoogleMapsLink(eventDetail
                                          .room.coordinates),
                                      Icon(Icons.location_on)),
                                  const Padding(padding: EdgeInsets.only(bottom: 4.0)),
                                  TextWithIcon(eventDetail.getDurationString(),
                                      Icon(Icons.today)),
                                  const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                                  Text(
                                      eventDetail.description,
                                      style: Theme.of(context).textTheme.subtitle1
                                  ),
                                  const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                                  Visibility(
                                    visible: eventDetail.status == "active",
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          ButtonTheme(
                                              minWidth: 120.0,
                                              child: OutlineButton(
                                                child: const Text('DISMISS'),
                                                textColor: Theme.of(context).accentColor,
                                                highlightedBorderColor: Theme.of(context).accentColor,
                                                onPressed: () {
                                                  if(!eventDetail.followed){
                                                    _showDismissDialog
                                                      (eventDetail);
                                                  } else {
                                                    dismissEventAction
                                                      (eventDetail);
                                                  }
                                                }
                                              )
                                          ),
                                          Padding(padding: EdgeInsets.only(
                                              left: 80.0)),
                                          ButtonTheme(
                                              minWidth: 120.0,
                                              child: OutlineButton(
                                                child: Text(eventDetail.followed ?
                                                "UNFOLLOW":'FOLLOW'
                                                ),
                                                textColor: Theme.of(context).primaryColor,
                                                borderSide: BorderSide(
                                                    color: Theme.of(context).primaryColor,
                                                    width: eventDetail.followed ? 1.5 : 0.0
                                                ),
                                                onPressed: () {
                                                  eventDetail.followed ?
                                                  unFollowEventAction
                                                    (MapEntry(FeedType.Detail, eventDetail
                                                  )) :
                                                  followEventAction
                                                    (MapEntry(FeedType.Detail, eventDetail
                                                  ));
                                                },
                                              )
                                          )
                                        ]
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                        //
                        // Links
                        Visibility(
                          visible: eventDetail.websites.length>0,
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
                                          .bodyText1.fontSize,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(
                                      bottom: 4.0)),
                                  ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(0),
                                      itemCount: eventDetail.websites.length,
                                      itemBuilder: (context, index) {
                                        Website website = eventDetail
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
                                              .bodyText1.fontSize,
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
                                              .bodyText1.fontSize,
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
                                              eventDetail.tags.length,
                                                  (i) => Chip(
                                                  label: Text(
                                                      eventDetail.tags[i].name
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

  Widget _buildError(Exception e){
    return Scaffold(
      appBar: AppBar(
        title: Text("Error"),
      ),
      body: Center(
        child: Container(
          child: Text(e.toString()),
        ),
      ),
    );
  }

  Widget _buildLoading(){
    return Scaffold(
      appBar: AppBar(
        title: Text("Loading"),
      ),
      body: Center(
        child: Container(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void _showDismissDialog(Event eventDetail){
    _dialogService.showDialog(
      type: DialogType.Alert,
      title: "Dismissing an Event",
      description: "Are you sure you want to dismiss this Evet?\n"
          "You will no longer see this event in your feeds",
      primaryButtonTitle: "CONFIRM",
      secondaryButtonTitle: "CANCEL"
    ).then((result) async{
      if(result.result){
        await dismissEventAction(eventDetail);
        confirmDismissAction(FeedType.Detail);
      }
    });
  }

}

