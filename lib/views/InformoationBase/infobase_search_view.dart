import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/InformoationBase/room_card.dart';
import 'package:InTheNou/views/InformoationBase/services_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class InfoBaseSearchView extends StatefulWidget {

  final InfoBaseSearchType searchType;

  InfoBaseSearchView(this.searchType);

  @override
  _InfoBaseSearchViewState createState() => new _InfoBaseSearchViewState();

}

class _InfoBaseSearchViewState extends State<InfoBaseSearchView>
  with flux.StoreWatcherMixin<InfoBaseSearchView>{

  TextEditingController _searchQueryController;
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
        title: _infoBaseStore.getIsSearching(widget.searchType) ? _buildSearchField() :
          Text(Utils.infoBaseSearchString(widget.searchType)),
        actions: _buildActions(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: showCorrectList(),
          )
        ],
      ),
    );
  }

  Widget showCorrectList(){
    switch (widget.searchType){
      case InfoBaseSearchType.Building:
        return showBuildingsResults();
        break;
      case InfoBaseSearchType.Room:
        return showRoomsResults();
        break;
      case InfoBaseSearchType.Service:
        return showServicesResults();
        break;
    }
  }

  Widget showBuildingsResults(){
    return ListView.builder(
        itemCount: _infoBaseStore.buildingsResults.length,
        controller: _scrollController,
        padding:const EdgeInsets.only(top: 8.0),
        itemBuilder: (context, index){
          Building building = _infoBaseStore.buildingsResults[index];
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
                  FadeInImage.assetNetwork(
                    fit: BoxFit.cover,
                    placeholder: "lib/assets/placeholder.png",
                    height: 120.0,
                    width: 150.0,
                    image: building.image,
                  ),
                  const Padding(padding: EdgeInsets.only(left: 16.0)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        building.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(padding: EdgeInsets.only(top: 8.0,
                          left: 8.0),
                          child: Text(
                            building.commonName,
                            style: Theme.of(context).textTheme.subtitle1,
                          )
                      ),
                    ],
                  )
                ],
              ),
            )
          );
        });
  }

  Widget showRoomsResults(){
    return ListView.builder(
        itemCount: _infoBaseStore.roomsResults.length,
        controller: _scrollController,
        itemBuilder: (context, index){
          Room room = _infoBaseStore.roomsResults[index];
          return RoomCard(room);
        });
  }

  Widget showServicesResults(){
    return ListView.builder(
        itemCount: _infoBaseStore.servicesResults.length,
        controller: _scrollController,
        itemBuilder: (context, index){
          Service service = _infoBaseStore.servicesResults[index];
          return ServicesCard(service);
        });
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
        searchInfoBaseAction(new MapEntry(widget.searchType, query));
      },
    );
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setSearchingAction(new MapEntry(widget.searchType, true));
  }

  void _stopSearching() {
    _scrollController.animateTo(0.0,
        curve: Curves.ease, duration: Duration(seconds: 2));
    _clearSearchKeyword();
    setSearchingAction(new MapEntry(widget.searchType, false));
    if(widget.searchType == InfoBaseSearchType.Building) {
      getAllBuildingsAction();
    }
  }

  void _clearSearchKeyword() {
    _searchQueryController.clear();
    clearInfoBaseKeywordAction(widget.searchType);
  }
}