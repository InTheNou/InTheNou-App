import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/stores/event_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:InTheNou/views/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class PersonalFeedView extends StatefulWidget{

  @override
  PersonalFeedState createState() => PersonalFeedState();
}

class PersonalFeedState extends State<PersonalFeedView>
    with flux.StoreWatcherMixin<PersonalFeedView>{

  EventFeedStore _eventFeedStore;
  UserStore _userStore;
  TextEditingController _searchQueryController = TextEditingController();
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _eventFeedStore = listenToStore(EventFeedStore.eventFeedToken);
    _userStore = UserStore();
    // if it's the first time the feed is loaded, get all the Events
    if (_eventFeedStore.eventCount(FeedType.PersonalFeed) == 0 &&
        !_eventFeedStore.isSearching(FeedType.PersonalFeed)){
      getAllEventsAction(FeedType.PersonalFeed);
    }
    //Save the scroll position the uer is in to recall if the screen is switched
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
            title: _buildTitle(),
            actions: _buildActions()
        ),
        body: buildBody(),
        floatingActionButton: new Visibility(
          visible: _userStore.user.userPrivilege != UserPrivilege.User,
          child: new FloatingActionButton(
            onPressed: (){
              Navigator.of(context).pushNamed('/create_event');
            },
            tooltip: 'Open Event Creation',
            child: new Icon(Icons.add),
          ),
        ),
    );
  }

  Widget buildBody(){
    if(_eventFeedStore.isFeedLoading(FeedType.PersonalFeed)){
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if(_eventFeedStore.getError(FeedType.PersonalFeed) !=null){
        showErrorDialog(_eventFeedStore.getError(FeedType.PersonalFeed));
      }
      return  ListView.builder(
          key: ValueKey(FeedType.PersonalFeed),
          controller: _scrollController,
          itemCount: _eventFeedStore.eventCount(FeedType.PersonalFeed),
          itemBuilder: (context, index) {
            return EventCard(_eventFeedStore.feedEvent(FeedType.PersonalFeed, index),
              FeedType.PersonalFeed);
          }
      );
    }
  }

  Future showErrorDialog(String errorText) async {
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
                  clearErrorAction(FeedType.PersonalFeed);
                },
              ),
            ],
        ),
      );
    });
  }

  /// Method called whenever the AppBar is being drawn, if the search button
  /// was selected then [_eventFeedStore.isSearching] will return true and
  /// the Search bar button will be drawn. If not then the Title will.
  Widget _buildTitle() {
    if(_eventFeedStore.isSearching(FeedType.PersonalFeed)){
      _searchQueryController.text = _eventFeedStore
          .searchKeyword(FeedType.PersonalFeed);
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
    return Text(Utils.feedTypeString(FeedType.PersonalFeed));
  }

  /// Method called whenever the AppBar is being drawn, if the search button
  /// was selected then [_eventFeedStore.isSearching] will return true and
  /// the Clear button will be drawn. If not then the Search button will.
  List<Widget> _buildActions() {
    if (_eventFeedStore.isSearching(FeedType.PersonalFeed)) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => _clearSearchKeyword()
        ),
      ];
    }
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _refresh,
      ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  /// Gets all the events from the database and also brings the user to the
  /// top of the page
  void _refresh() {
    getAllEventsAction(FeedType.PersonalFeed);
    _scrollController.animateTo(0.0,
        curve: Curves.ease, duration: Duration(seconds: 2));
  }

  void _startSearch() {
    setFeedSearching(new MapEntry(FeedType.PersonalFeed, true));
  }

  void _clearSearchKeyword() {
    if(_searchQueryController == null ||
        _searchQueryController.text.isEmpty){
      _scrollController.animateTo(0.0,
          curve: Curves.ease, duration: Duration(seconds: 2));
      setFeedSearching(new MapEntry(FeedType.PersonalFeed, false));
      getAllEventsAction(FeedType.PersonalFeed);
      return;
    }
    _searchQueryController.clear();
    clearSearchKeywordAction(FeedType.PersonalFeed);
  }

}