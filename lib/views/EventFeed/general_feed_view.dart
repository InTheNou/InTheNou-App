import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/stores/event_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:InTheNou/views/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class GeneralFeedView extends StatefulWidget{

  final FeedType type;
  GeneralFeedView({this.type}) : super(key: ValueKey(Utils.feedTypeString(type)));

  @override
  GeneralFeedState createState() => GeneralFeedState();
}

class GeneralFeedState extends State<GeneralFeedView>
    with flux.StoreWatcherMixin<GeneralFeedView>{

  EventFeedStore _eventFeedStore;
  UserStore _userStore;
  TextEditingController _searchQueryController;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    /// if it's the first time the feed is loaded, get all the Events
    _eventFeedStore = listenToStore(EventFeedStore.eventFeedToken);
    _userStore = UserStore();
    if (_eventFeedStore.eventCount(widget.type) == 0 &&
        !_eventFeedStore.isSearching(widget.type)){
      getAllEventsAction(widget.type);
    }
    /// Save the scroll position the uer is in to recall if the screen is
    /// switched
    _scrollController = ScrollController(
        initialScrollOffset: _eventFeedStore.genScrollPos);
    _scrollController.addListener(() {
      _eventFeedStore.genScrollPos = _scrollController.offset;
    });
    _searchQueryController =TextEditingController(
        text:_eventFeedStore.searchKeyword(widget.type));
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
          key: ValueKey("EventCreationFAB"),
          visible: widget.type == FeedType.PersonalFeed &&
              _userStore.user.userPrivilege != UserPrivilege.User,
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
    if(_eventFeedStore.isFeedLoading(widget.type)){
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if(_eventFeedStore.getError(widget.type) !=null){
        showErrorDialog(_eventFeedStore.getError(widget.type));
      }
      if(_eventFeedStore.isSearching(widget.type)
          && _eventFeedStore.eventCount(widget.type) == 0){
        return Center(
          child: Text("No resulsts Found",
              style: Theme.of(context).textTheme.headline5.copyWith(
                  fontWeight: FontWeight.w200
              )),
        );
      } else if(_eventFeedStore.eventCount(widget.type) == 0){
        return Center(
          child: Text("No Events at this time",
              style: Theme.of(context).textTheme.headline5.copyWith(
                  fontWeight: FontWeight.w200
              )),
        );
      }
      return  ListView.builder(
          key: ValueKey(widget.type),
          controller: _scrollController,
          itemCount: _eventFeedStore.eventCount(widget.type),
          itemBuilder: (context, index) {
            return EventCard(_eventFeedStore.feedEvent(widget.type, index),
                widget.type);
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
                clearErrorAction(widget.type);
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
    if(_eventFeedStore.isSearching(widget.type)){
      _searchQueryController.text = _eventFeedStore
          .searchKeyword(widget.type);
      return TextField(
        controller: _searchQueryController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Search Events...",
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.white,
        ),
        onSubmitted: (query) {
          if(_scrollController.hasClients){
            _scrollController.animateTo(0.0,
                curve: Curves.ease, duration: Duration(seconds: 2));
          }
          searchFeedAction(new MapEntry(widget.type, query));
        },
      );
    }
    return Text(Utils.feedTypeString(widget.type));
  }

  /// Method called whenever the AppBar is being drawn, if the search button
  /// was selected then [_eventFeedStore.isSearching] will return true and
  /// the Clear button will be drawn. If not then the Search button will.
  List<Widget> _buildActions() {
    if (_eventFeedStore.isSearching(widget.type)) {
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
    getAllEventsAction(widget.type);
    if(_scrollController.hasClients){
      _scrollController.animateTo(0.0,
          curve: Curves.ease, duration: Duration(seconds: 2));
    }
  }

  void _startSearch() {
    setFeedSearching(new MapEntry(widget.type, true));
  }

  void _clearSearchKeyword() {
    if(_searchQueryController == null ||
        _searchQueryController.text.isEmpty){
      if(_scrollController.hasClients){
        _scrollController.animateTo(0.0,
            curve: Curves.ease, duration: Duration(seconds: 2));
      }
      setFeedSearching(new MapEntry(widget.type, false));
      getAllEventsAction(widget.type);
      return;
    }
    _searchQueryController.clear();
    clearSearchKeywordAction(widget.type);
  }

}