import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:InTheNou/views/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class FeedView extends StatefulWidget{

  final FeedType type;
  FeedView({this.type}) : super(key: PageStorageKey(Utils.feedTypeString(type)));

  @override
  GeneralFeedState createState() => GeneralFeedState();
}

class GeneralFeedState extends State<FeedView>
    with flux.StoreWatcherMixin<FeedView>{

  EventFeedStore _eventFeedStore;
  UserStore _userStore;
  TextEditingController _searchQueryController;
  FocusNode _searchFocus;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    /// if it's the first time the feed is loaded, get all the Events
    _eventFeedStore = listenToStore(EventFeedStore.eventFeedToken);
    _userStore = listenToStore(UserStore.userStoreToken);
    /// Save the scroll position the uer is in to recall if the screen is
    /// switched
    _scrollController = ScrollController(
        initialScrollOffset: _eventFeedStore.getScrollPos(widget.type));
    _scrollController.addListener(() {
      _eventFeedStore.setScrollPos(widget.type, _scrollController.offset);
    });
    _searchQueryController =TextEditingController(
        text:_eventFeedStore.searchKeyword(widget.type));
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: _buildTitle(),
            actions: _buildActions()
        ),
        body: _buildBody(),
        floatingActionButton: new Visibility(
          key: ValueKey("EventCreationFAB"),
          visible: widget.type == FeedType.PersonalFeed &&
              _userStore.user != null &&
              _userStore.user.userPrivilege != UserPrivilege.User,
          child: new FloatingActionButton(
            onPressed: (){
              Navigator.of(context).pushNamed('/create_event');
            },
            tooltip: 'Open Event Creation',
            backgroundColor: Theme.of(context).primaryColor,
            child: new Icon(Icons.add),
          ),
        ),
    );
  }

  /// Builds the Title child of the AppBar
  ///
  /// Method called whenever the AppBar is being drawn, if the search button
  /// was selected then [_eventFeedStore.isSearching] will return true and
  /// the Search bar button will be drawn. If not then the Title will.
  Widget _buildTitle() {
    if(_eventFeedStore.isSearching(widget.type)){
      return TextField(
        controller: _searchQueryController,
        autofocus: false,
        focusNode: _searchFocus,
        decoration: InputDecoration(
          hintText: "Search Events...",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: TextStyle(color: Colors.white, fontSize: 16.0),
        onSubmitted: (query) {
          if(query.trim().length > 0){
            if(_scrollController.hasClients){
              _scrollController.animateTo(0.0,
                  curve: Curves.ease, duration: Duration(seconds: 1))
                  .then((value){
                searchFeedAction(new MapEntry(widget.type, query.trim()));
              });
            } else {
              searchFeedAction(new MapEntry(widget.type, query.trim()));
            }
          }
        },
      );
    }
    return Text(Utils.feedTypeString(widget.type));
  }

  /// Creates the Actions of the AppBar
  ///
  /// Method called whenever the AppBar is being drawn, if the search button
  /// was selected then [_eventFeedStore.isSearching] will return true and
  /// the Clear button will be drawn. If not then the Search button will.
  List<Widget> _buildActions() {
    if (_eventFeedStore.isSearching(widget.type)) {
      return <Widget>[
        IconButton(
            icon: const Icon(Icons.clear),
            tooltip: "Clear and Close",
            onPressed: () => _clearSearchKeyword()
        ),
      ];
    }
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: "Refresh Feed",
        onPressed: () => _refresh(),
      ),
      IconButton(
        icon: const Icon(Icons.search),
        tooltip: "Search Feed",
        onPressed: () {
          setFeedSearching(new MapEntry(widget.type, true));
          _searchFocus.requestFocus();
        },
      ),
    ];
  }

  Widget _buildBody(){
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: FutureBuilder(
        future: widget.type == FeedType.PersonalFeed ?
          _eventFeedStore.personalSearch : _eventFeedStore.generalSearch,
        builder: (BuildContext context, AsyncSnapshot<List<Event>> events) {

          if(events.hasData){
            if(events.data.length == 0 && _eventFeedStore.isSearching(widget.type)){
              return Center(
                child: Text("No resulsts Found",
                    style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.w200
                    )),
              );
            } else if(events.data.length == 0){
              return Center(
                child: Text("No Events at this time",
                    style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.w200
                    )),
              );
            } else {
              return  ListView.builder(
                  key: ValueKey(widget.type),
                  controller: _scrollController,
                  itemCount: events.data.length,
                  itemBuilder: (context, index) {
                    return EventCard(events.data[index], widget.type);
                  }
              );
            }
          } else if(events.hasError){
            return _buildErrorWidget(events.error.toString());
          }
          return _buildLoadingWidget();
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(error,
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
          ],
        ));
  }

  Widget _buildLoadingWidget(){
    return Center(
      child: Container(
        height: 100,
        width: 100,
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Gets all the events from the database calling [getAllEventsAction] and
  /// also brings the user to the top of the page
  void _refresh() {
    if(_scrollController.hasClients){
      _scrollController.animateTo(0.0,
          curve: Curves.ease, duration: Duration(seconds: 1))
          .then((value) {
        getAllEventsAction(widget.type);
      });
    } else {
      getAllEventsAction(widget.type);
    }
  }

  /// Clears the field of the search bar and also hides the search bar
  ///
  /// If the search has a keyword input then it will be cleared. Otherwise
  /// the search bar is hidden by calling [setFeedSearching] with false. This
  /// also scrolls to the top of the page in case the user has scrolled down
  /// and gathers all the events again calling [getAllEventsAction]
  void _clearSearchKeyword() {
    if(_searchQueryController == null ||
        _searchQueryController.text.isEmpty){
      if(_scrollController.hasClients){
        _scrollController.animateTo(0.0,
            curve: Curves.ease, duration: Duration(seconds: 1))
            .then((value) {
          setFeedSearching(new MapEntry(widget.type, false));
          getAllEventsAction(widget.type);
        });
      } else {
        setFeedSearching(new MapEntry(widget.type, false));
        getAllEventsAction(widget.type);
      }
      return;
    }
    _searchQueryController.clear();
    clearSearchKeywordAction(widget.type);
  }

}