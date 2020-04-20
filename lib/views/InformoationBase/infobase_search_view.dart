import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/InformoationBase/room_card.dart';
import 'package:InTheNou/views/InformoationBase/services_card.dart';
import 'package:InTheNou/views/widgets/loading_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

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
    getAllBuildingsAction(widget.searchType);
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
        if(results.hasData){
          if(results.data.length == 0){
            return _buildNoResultsNotice();
          } else if(widget.searchType == InfoBaseType.Building){
            return showBuildingsResults(results.data);
          } else if (widget.searchType == InfoBaseType.Room){
            return showRoomsResults(results.data);
          } else {
            return showServicesResults(results.data);
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

  Widget showBuildingsResults(List<Building> buildingsResults){
    return ListView.builder(
        itemCount: buildingsResults.length,
        controller: _scrollController,
        padding:const EdgeInsets.only(top: 8.0),
        itemBuilder: (context, index){
          Building building = buildingsResults[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed("/infobase/building");
                selectBuildingAction(building);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  LoadingImage(
                      imageURL: building.image,
                      height: 120.0,
                      width: 150.0
                  ),
                  const Padding(padding: EdgeInsets.only(left: 16.0)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          building.commonName,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.headline6,
                          softWrap: true,
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          building.name,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                          softWrap: true,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          );
        });
  }

  Widget showRoomsResults(List<Room> roomsResults){
    return ListView.builder(
        itemCount: roomsResults.length,
        controller: _scrollController,
        itemBuilder: (context, index){
          Room room = roomsResults[index];
          return RoomCard(room);
        });
  }

  Widget showServicesResults(List<Service> servicesResults){
    return ListView.builder(
        itemCount: servicesResults.length,
        controller: _scrollController,
        itemBuilder: (context, index){
          Service service = servicesResults[index];
          return ServicesCard(service);
        });
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
          searchInfoBaseAction(new MapEntry(widget.searchType, query.trim()));
        }
      },
    );
  }

  String _buildHint(InfoBaseType type){
    if(type == InfoBaseType.Building){
      return "Search: Stefani";
    } else if (type == InfoBaseType.Service){
      return "Search: S-100, Salon";
    } else {
      return "Search: Oficina";
    }
  }

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
    clearInfoBaseKeywordAction(widget.searchType);
  }

}