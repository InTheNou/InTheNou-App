import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:InTheNou/views/widgets/error_body_widget.dart';
import 'package:InTheNou/views/widgets/event_card_image.dart';
import 'package:InTheNou/views/widgets/loading_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

/// The view for showing [Event] results
///
/// This View is used for both the Personal Feed and the General Feed
///
/// {@category View}
class FeedView extends StatefulWidget{

  final FeedType type;
  FeedView({this.type, Key key}) : super(key: key);

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

    // if it's the first time the feed is loaded, get all the Events
    _eventFeedStore = listenToStore(EventFeedStore.eventFeedToken);
    _userStore = listenToStore(UserStore.userStoreToken);
    // Save the scroll position the user is in to recall if the screen is
    // switched
    _scrollController = ScrollController(
        initialScrollOffset: _eventFeedStore.getScrollPos(widget.type));
    _scrollController.addListener(() {
      _eventFeedStore.setScrollPos(widget.type, _scrollController.offset);
    });
    _searchQueryController =TextEditingController(
        text:_eventFeedStore.searchKeyword(widget.type));
    _searchFocus = FocusNode();

    if(_eventFeedStore.getResults(widget.type).length == 0 &&
        !_eventFeedStore.isSearching(widget.type)){
      getAllEventsAction(widget.type);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _searchQueryController.dispose();
    _searchFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: _buildTitle(),
            actions: _buildActions()
        ),
        body: _buildBody(),
        floatingActionButton: Visibility(
          key: ValueKey("EventCreationFAB"),
          visible:
              _userStore.user != null &&
              _userStore.user.userPrivilege != UserPrivilege.User,
          child: FloatingActionButton(
            onPressed: (){
              Navigator.of(context).pushNamed('/create_event');
            },
            tooltip: 'Open Event Creation',
            child: Icon(Icons.add),
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
        maxLength: 25,
        maxLengthEnforced: true,
        decoration: InputDecoration(
            hintText: "Search Events...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
            counterStyle: TextStyle(height: double.minPositive,),
            counterText: ""
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

  Future future;
  Widget _buildBody(){
    future = widget.type == FeedType.PersonalFeed ?
    _eventFeedStore.personalSearch : _eventFeedStore.generalSearch;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: FutureBuilder<List<Event>>(
        key: ValueKey(widget.type.toString() + "futurebuilder"),
        future: future,
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
              return _buildResults(events.data);
            }
          } else if(events.hasError){
            return ErrorBodyWidget(events.error);
          }
          return LoadingBodyWidget();
        },
      ),
    );
  }
  Widget _buildResults(List<Event> results){
    return Scrollbar(
      child: RefreshIndicator(
          onRefresh: () => getAllEventsAction(widget.type),
          child: NotificationListener<ScrollNotification>(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: ListView.builder(
                        key: ValueKey(widget.type.toString()+ "listView"),
                        itemCount: results.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 75),
                        itemBuilder: (context, index){
                          return EventCardImage(results[index], widget.type);
                        }),
                  ),
                  Container(
                    height: _eventFeedStore.getIsPaginating(widget.type) ? 75 : 0,
                    color: Colors.transparent,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ],
              ),
            ),
            onNotification: (ScrollNotification scrollInfo) {
              if (!_eventFeedStore.getIsPaginating(widget.type) &&
                  _eventFeedStore.getCanPaginate(widget.type) &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent-250 &&
                  scrollInfo.metrics.pixels <=
                      scrollInfo.metrics.maxScrollExtent-25) {
                paginateFeedAction(widget.type);
                return true;
              }
              return false;
            },
          )
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