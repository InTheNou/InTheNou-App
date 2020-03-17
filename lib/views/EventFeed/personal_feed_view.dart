import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

const String PERSONAL_FEED = "Personal Feed";
const String FEED_TYPE = "personal";

class PersonalFeedView extends StatefulWidget{

  @override
  PersonalFeedState createState() => PersonalFeedState();
}

class PersonalFeedState extends State<PersonalFeedView>
    with flux.StoreWatcherMixin<PersonalFeedView>{

  EventFeedStore eventFeedStore;
  TextEditingController _searchQueryController = TextEditingController();
  ScrollController _scrollController;

  final snackBar = SnackBar(
    content: Text('Undo Dismiss'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        undoDismissAction(FEED_TYPE);
      },
    ),
  );

  @override
  void initState() {
    super.initState();

    eventFeedStore = listenToStore(EventFeedStore.eventFeedToken);
    getAllEventsAction(FEED_TYPE);
    _scrollController = ScrollController(
        initialScrollOffset: eventFeedStore.genScrollPos);
    _scrollController.addListener(() {
      eventFeedStore.genScrollPos = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: eventFeedStore.isSearching(FEED_TYPE) ? _buildSearchField() :
            Text(PERSONAL_FEED),
            actions: _buildActions()
        ),
        body: ListView.builder(
          key: ValueKey(FEED_TYPE),
          controller: _scrollController,
          itemCount: eventFeedStore.eventCount(FEED_TYPE),
          itemBuilder: (context, index) {
            Event _event = eventFeedStore.feedEvent(FEED_TYPE, index);
            return Card(
              key: ValueKey(_event.UID),
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
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                OutlineButton(
                                  child: Text('DISMISS'),
                                  textColor: Theme.of(context).accentColor,
                                  highlightedBorderColor: Theme.of(context).accentColor,
                                  onPressed: () {
                                    dismissEvent(_event);
                                  },
                                ),
                                Padding(padding: EdgeInsets.only(left: 30.0)),
                                ButtonTheme(
                                    minWidth: 120.0,
                                    child: OutlineButton(
                                      child: Text(_event.followed ?
                                      "UNFOLLOW":'FOLLOW'
                                      ),
                                      textColor: Theme.of(context).primaryColor,
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: _event.followed ? 1.5 : 0.0
                                      ),
                                      onPressed: () {
                                        _event.followed ?
                                        unFollowEventAction(_event.UID) :
                                        followEventAction(_event.UID);
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
            );
          },
        )
    );
  }

  void dismissEvent(Event event){
    Scaffold.of(context).showSnackBar(snackBar).closed
        .then((SnackBarClosedReason reason) {
      if (reason == SnackBarClosedReason.dismiss ||
          reason == SnackBarClosedReason.hide ||
          reason == SnackBarClosedReason.remove ||
          reason == SnackBarClosedReason.timeout){
        confirmDismissAction();
      }
    });

    dismissEventAction(MapEntry(FEED_TYPE, event.UID));
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Events...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onSubmitted: (query) {
        _scrollController.animateTo(0.0,
            curve: Curves.ease, duration: Duration(seconds: 1));
        searchFeedAction(new MapEntry(FEED_TYPE, query));
      },
    );
  }

  List<Widget> _buildActions() {
    if (eventFeedStore.isSearching(FEED_TYPE)) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchKeyword();
          },
        ),
      ];
    }
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setFeedSearching(new MapEntry(FEED_TYPE, true));
  }

  void _stopSearching() {
    _scrollController.animateTo(0.0,
        curve: Curves.ease, duration: Duration(seconds: 2));
    _clearSearchKeyword();
    setFeedSearching(new MapEntry(FEED_TYPE, false));
    getAllEventsAction(FEED_TYPE);
  }

  void _clearSearchKeyword() {
    _searchQueryController.clear();
    clearSearchKeywordAction(FEED_TYPE);
  }

}