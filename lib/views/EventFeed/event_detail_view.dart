import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
import 'package:InTheNou/views/widgets/cancel_button.dart';
import 'package:InTheNou/views/widgets/dismiss_button.dart';
import 'package:InTheNou/views/widgets/error_scaffold_view.dart';
import 'package:InTheNou/views/widgets/follow_button.dart';
import 'package:InTheNou/views/widgets/link_with_icon_widget.dart';
import 'package:InTheNou/views/widgets/loading_image.dart';
import 'package:InTheNou/views/widgets/loading_scaffold_view.dart';
import 'package:InTheNou/views/widgets/multi_text_with_icon_widget.dart';
import 'package:InTheNou/views/widgets/text_with_icon_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


/// The view for showing detailed information about a selected [Event]
///
/// {@category View}
class EventDetailView extends StatefulWidget {

  final int _initialEvent;

  EventDetailView(this._initialEvent);

  @override
  _EventDetailViewState createState() => new _EventDetailViewState();

}

class _EventDetailViewState extends State<EventDetailView>
    with flux.StoreWatcherMixin<EventDetailView>{
  EventFeedStore _eventFeedStore;

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
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<Event> eventDetail) {

        if(eventDetail.hasData){
          return _buildBody(eventDetail.data);
        } else if(eventDetail.hasError){
          return ErrorScaffoldView(eventDetail.error);
        }
        return LoadingScaffoldView();
      },
    );
  }

  Widget _buildBody(Event eventDetail){
    // If the user has chosen to dismiss the event then the detailed view
    // will close
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
                    color: Colors.white
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
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
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
                              color: Theme.of(context).brightness == Brightness.dark ?
                              Theme.of(context).primaryColorLight :
                              Theme.of(context).primaryColor,
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
                          TextWithIcon(eventDetail.getDurationString(),
                              Icon(Icons.today)),
                          const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                          Text(
                              eventDetail.description,
                              style: Theme.of(context).textTheme.subtitle1
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                          Visibility(
                            visible: eventDetail.status == "active" 
                                && !eventDetail.dismissed 
                                && eventDetail.endDateTime.isAfter(DateTime.now()),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  DismissButton(eventDetail, FeedType.Detail),
                                  FollowButton(eventDetail, FeedType.Detail),
                                ]
                            ),
                          ),
                          Visibility(
                            visible: eventDetail.status != "active",
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  SizedBox(
                                    width: 110,
                                  ),
                                  Padding(padding: EdgeInsets.only(
                                      left: 80.0)),
                                  CancelButton(eventDetail),
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
                              color: Theme.of(context).brightness == Brightness.dark ?
                              Theme.of(context).primaryColorLight :
                              Theme.of(context).primaryColor,
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
                Visibility(
                  visible: eventDetail.followed,
                  child: Card(
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
                                    color: Theme.of(context).brightness == Brightness.dark ?
                                    Theme.of(context).primaryColorLight :
                                    Theme.of(context).primaryColor,
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
                                  color: Theme.of(context).brightness == Brightness.dark ?
                                  Theme.of(context).primaryColorLight :
                                  Theme.of(context).primaryColor,
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
                                          (i) => Chip(label:
                                      Text(eventDetail.tags[i].name)
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
      ),
    );
  }

}

