import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class PersonalFeedView extends StatefulWidget{

  @override
  PersonalFeedState createState() => PersonalFeedState();
}

class PersonalFeedState extends State<PersonalFeedView>
    with flux.StoreWatcherMixin<PersonalFeedView>{

  EventFeedStore _eventFeedStore;
  TextEditingController _searchQueryController = TextEditingController();
  ScrollController _scrollController;

  final snackBar = SnackBar(
    content: Text('Undo Dismiss'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        undoDismissAction();
      },
    ),
  );

  @override
  void initState() {
    super.initState();

    _eventFeedStore = listenToStore(EventFeedStore.eventFeedToken);
    if (_eventFeedStore.eventCount(FeedType.PersonalFeed) == 0){
      getAllEventsAction(FeedType.PersonalFeed);
    }
    _scrollController = ScrollController(
        initialScrollOffset: _eventFeedStore.perScrollPos);
    _scrollController.addListener(() {
      _eventFeedStore.perScrollPos = _scrollController.offset;
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
            title: _eventFeedStore.isSearching(FeedType.PersonalFeed) ?
            _buildSearchField() : Text(feedTypeString(FeedType.PersonalFeed)),
            actions: _buildActions()
        ),
        body: ListView.builder(
          key: ValueKey(FeedType.PersonalFeed),
          controller: _scrollController,
          itemCount: _eventFeedStore.eventCount(FeedType.PersonalFeed),
          itemBuilder: (context, index) {
            Event _event = _eventFeedStore.feedEvent(FeedType.PersonalFeed, index);
            return Card(
              key: ValueKey(_event.UID),
              child: InkWell(
                onTap: () {
                  openEventDetail(MapEntry(FeedType.PersonalFeed, _event.UID));
                  Navigator.of(context).pushNamed(
                      '/eventdetail',
                    arguments: FeedType.PersonalFeed
                  );
                },
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
              )
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

    dismissEventAction(event.UID);
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
        searchFeedAction(new MapEntry(FeedType.PersonalFeed, query));
      },
    );
  }

  List<Widget> _buildActions() {
    if (_eventFeedStore.isSearching(FeedType.PersonalFeed)) {
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
    setFeedSearching(new MapEntry(FeedType.PersonalFeed, true));
  }

  void _stopSearching() {
    _scrollController.animateTo(0.0,
        curve: Curves.ease, duration: Duration(seconds: 2));
    _clearSearchKeyword();
    setFeedSearching(new MapEntry(FeedType.PersonalFeed, false));
    getAllEventsAction(FeedType.PersonalFeed);
  }

  void _clearSearchKeyword() {
    _searchQueryController.clear();
    clearSearchKeywordAction(FeedType.PersonalFeed);
  }

}