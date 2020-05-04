import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/InformoationBase/building_card.dart';
import 'package:InTheNou/views/InformoationBase/room_card.dart';
import 'package:InTheNou/views/InformoationBase/services_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

/// The view for searching the information base after selecting a category
///
/// This view handles the [Building], [Room] and [Service]  results in one.
/// It can be expanded in the future to accommodate other types of information.
///
/// {@category View}
class InfoBaseSearchView extends StatefulWidget {

  final InfoBaseType searchType;

  InfoBaseSearchView(this.searchType);

  @override
  _InfoBaseSearchViewState createState() => new _InfoBaseSearchViewState();

}

class _InfoBaseSearchViewState extends State<InfoBaseSearchView>
  with flux.StoreWatcherMixin<InfoBaseSearchView>{

  TextEditingController _searchQueryController;
  FocusNode _searchFocus;
  ScrollController _scrollController;
  InfoBaseStore _infoBaseStore;

  @override
  void initState() {
    super.initState();
    _infoBaseStore = listenToStore(InfoBaseStore.infoBaseToken);
    _scrollController = ScrollController();
    if(widget.searchType == InfoBaseType.Building){
      getAllBuildingsAction();
    }
    _searchQueryController = TextEditingController(
      text: _infoBaseStore.getSearchKeyword(widget.searchType));
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
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _infoBaseStore.getIsSearching(widget.searchType) ? _buildSearchField() :
            Text(Utils.infoBaseSearchString(widget.searchType)),
          actions: _buildActions(),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _buildBody(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody(){
    Future dataToShow;
    if(widget.searchType == InfoBaseType.Building){
      dataToShow = _infoBaseStore.buildingsResults;
    } else if (widget.searchType == InfoBaseType.Room){
      dataToShow = _infoBaseStore.roomsResults;
    } else {
      dataToShow = _infoBaseStore.servicesResults;
    }
    return FutureBuilder(
      future: dataToShow,
      builder: (BuildContext context, AsyncSnapshot<dynamic> results) {

        if(!_infoBaseStore.getIsPaginating(widget.searchType) &&
            results.connectionState == ConnectionState.waiting){
          return _buildLoadingWidget();
        }
        if(results.hasData){
          if(results.data.length == 0){
            return _buildNoResultsNotice();
          } else {
            return _buildResults(results.data);
          }
        }
        else if(results.hasError){
          return _buildErrorWidget(results.error.toString());
        }
        if(widget.searchType == InfoBaseType.Building){
          return _buildLoadingWidget();
        } else if (widget.searchType == InfoBaseType.Room){
          return _buildSearchNotice();
        } else {
          return _buildSearchNotice();
        }
      },
    );
  }

  Widget _buildResults(List<dynamic> results){
    return Scrollbar(
      child: RefreshIndicator(
          onRefresh: () => reloadSearchAction(widget.searchType),
          child: NotificationListener<ScrollNotification>(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: ListView.builder(
                        key: ValueKey(widget.searchType),
                        itemCount: results.length,
                        controller: _scrollController,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 75),
                        itemBuilder: (context, index){
                          if(widget.searchType == InfoBaseType.Building){
                            return BuildingCard(results[index]);
                          } else if (widget.searchType == InfoBaseType.Room){
                            return RoomCard(results[index]);
                          } else {
                            return ServicesCard(results[index]);
                          }
                        }),
                  ),
                  Container(
                    height: _infoBaseStore.getIsPaginating(widget.searchType) ? 75 : 0,
                    color: Colors.transparent,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ],
              ),
            ),
            onNotification: (ScrollNotification scrollInfo) {
              if (!_infoBaseStore.getIsPaginating(widget.searchType) &&
                  _infoBaseStore.getCanPaginate(widget.searchType) &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent-250 &&
                  scrollInfo.metrics.pixels <=
                      scrollInfo.metrics.maxScrollExtent-25) {
                paginateInfoBaseAction(widget.searchType);
                return true;
              }
              return false;
            },
          )
      ),
    );
  }


  Widget _buildErrorWidget(String error){
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
        )
    );
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

  Widget _buildSearchNotice(){
    return Center(
      child: Text("Initiate a Search",
          style: Theme.of(context).textTheme.headline5.copyWith(
              fontWeight: FontWeight.w200
          )),
    );
  }

  Widget _buildNoResultsNotice(){
    return Center(
      child: Text("No Results",
          style: Theme.of(context).textTheme.headline5.copyWith(
              fontWeight: FontWeight.w200
          )),
    );
  }

  List<Widget> _buildActions() {
    if (_infoBaseStore.getIsSearching(widget.searchType)) {
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: false,
      focusNode: _searchFocus,
      decoration: InputDecoration(
        hintText: _buildHint(widget.searchType),
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onSubmitted: (query) {
        if(query.trim().length > 0){
          if(_scrollController.hasClients){
            _scrollController.animateTo(0.0, curve: Curves.ease,
                duration: Duration(seconds: 1));
          }
          searchInfoBaseAction(MapEntry(widget.searchType, query.trim()));
        }
      },
    );
  }

  /// Creates the search hint based on the type of information being shown
  String _buildHint(InfoBaseType type){
    if(type == InfoBaseType.Building){
      return "Search: Stefani";
    } else if (type == InfoBaseType.Room){
      return "Search: S-100, Salon";
    } else {
      return "Search: Office";
    }
  }

  /// Sets upt the view for searching the selected category
  void _startSearch() {
    _searchFocus.requestFocus();
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setSearchingAction(new MapEntry(widget.searchType, true));
  }

  void _stopSearching() {
    if(_scrollController.hasClients){
      _scrollController.animateTo(0.0,
          curve: Curves.ease, duration: Duration(seconds: 2));
    }
//    _clearSearchKeyword();
    setSearchingAction(new MapEntry(widget.searchType, false));
    if(widget.searchType == InfoBaseType.Building) {
      getAllBuildingsAction();
    }
  }

  void _clearSearchKeyword() {
    _searchQueryController.clear();
//    clearInfoBaseKeywordAction(widget.searchType);
  }

}