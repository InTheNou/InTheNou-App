import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/repos/infobase_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class InfoBaseStore extends flux.Store{

  static final flux.StoreToken infoBaseToken = new flux.StoreToken(new
  InfoBaseStore());
  List<Building> _buildingsResults = new List();
  List<Room> _roomsInBuilding;
  List<Room> _roomsResults = new List();
  List<Service> _servicesInRoom = new List();
  List<Service> _servicesResults = new List();

  Building _detailBuilding;
  Room _detailRoom;
  Floor _selectedFloor;
  Service _detailService;

  bool _isBuildingSearching = false;
  bool _isRoomSearching = false;
  bool _isServiceSearching = false;

  String _buildingSearchKeyword;
  String _roomSearchKeyword;
  String _serviceSearchKeyword;

  InfoBaseRepo _infoBaseRepo = new InfoBaseRepo();

  InfoBaseStore() {
    triggerOnAction(searchInfoBaseAction,
        (MapEntry<InfoBaseSearchType, String> search){
      switch(search.key){
        case InfoBaseSearchType.Building:
          _buildingsResults = _infoBaseRepo.searchBuildings(search.value);
          break;
        case InfoBaseSearchType.Room:
          _roomsResults = _infoBaseRepo.searchRooms(search.value);
          break;
        case InfoBaseSearchType.Service:
          _servicesResults = _infoBaseRepo.searchServices(search.value);
          break;
      }
    });
    triggerOnAction(setSearchingAction,
            (MapEntry<InfoBaseSearchType, bool> searching){
      switch (searching.key){
        case InfoBaseSearchType.Building:
          _isBuildingSearching = searching.value;
          break;
        case InfoBaseSearchType.Room:
          _isRoomSearching = searching.value;
          break;
        case InfoBaseSearchType.Service:
          _isServiceSearching = searching.value;
          break;
      }

    });
    triggerOnAction(clearInfoBaseKeywordAction,
            (InfoBaseSearchType searching){
              switch(searching){
                case InfoBaseSearchType.Building:
                  _buildingSearchKeyword = "";
                  break;
                case InfoBaseSearchType.Room:
                  _roomSearchKeyword = "";
                  break;
                case InfoBaseSearchType.Service:
                  _serviceSearchKeyword = "";
                  break;
              }
    });
    triggerOnConditionalAction(getAllBuildingsAction, (_) async{
      return _infoBaseRepo.getAllBuildings().then((buildings){
        _buildingsResults = buildings;
        return true;
      });
    });

    triggerOnConditionalAction(selectBuildingAction, (Building building) async{
      if(_detailBuilding == building){
        return false;
      }
      _detailRoom = null;
      trigger();
      return _infoBaseRepo.getBuilding(building.UID).then((value) {
        _detailBuilding = value;
        return true;
      });
    });
    triggerOnConditionalAction(selectFloorAction,
            (MapEntry<Building,Floor> floor) async{
      if(selectedFloor ==  floor.value){
        return false;
      }
      _selectedFloor = floor.value;
      _roomsInBuilding = null;
      trigger();
      return _infoBaseRepo.getRoomsOfFloor(floor.key.UID, floor.value
          .floorNumber).then((value){
        _roomsInBuilding = value;
        return true;
      });
    });
    triggerOnConditionalAction(selectRoomAction, (Room room){
      if(_detailRoom == room){
        return false;
      }
      _detailRoom = null;
      trigger();
      return _infoBaseRepo.getRoom(room.UID).then((value) {
        _detailRoom = value;
        _servicesInRoom = _detailRoom.services;
        return true;
      });
    });
    triggerOnAction(selectServiceAction, (Service service){
      if(_detailService == service){
        return false;
      }
      _detailService = null;
      trigger();
      return _infoBaseRepo.getService(service.UID).then((value) {
        _detailService = value;
        return true;
      });
    });
  }

  List<Building> get buildingsResults => _buildingsResults;
  List<Room> get roomsInBuilding => _roomsInBuilding;
  List<Room> get roomsResults => _roomsResults;
  List<Service> get servicesInRoom => _servicesInRoom;
  List<Service> get servicesResults => _servicesResults;
  Building get detailBuilding => _detailBuilding;
  Floor get selectedFloor => _selectedFloor;
  Room get detailRoom => _detailRoom;
  Service get detailService => _detailService;

  bool getIsSearching(InfoBaseSearchType type){
    switch(type){
      case InfoBaseSearchType.Building:
        return _isBuildingSearching;
      case InfoBaseSearchType.Room:
        return _isRoomSearching;
      case InfoBaseSearchType.Service:
        return _isServiceSearching;
    }
    return false;
  }
  String getSearchKeyword(InfoBaseSearchType type){
    switch(type){
      case InfoBaseSearchType.Building:
        return _buildingSearchKeyword;
      case InfoBaseSearchType.Room:
        return _roomSearchKeyword;
      case InfoBaseSearchType.Service:
        return _serviceSearchKeyword;
    }
    return null;
  }

}

final flux.Action<MapEntry<InfoBaseSearchType, String>> searchInfoBaseAction = new
  flux.Action();
final flux.Action<MapEntry<InfoBaseSearchType, bool>> setSearchingAction = new
  flux.Action();
final flux.Action<InfoBaseSearchType> clearInfoBaseKeywordAction = new
  flux.Action();
final flux.Action getAllBuildingsAction = new flux.Action();
final flux.Action<Building> selectBuildingAction = new flux.Action();
final flux.Action<MapEntry<Building,Floor>> selectFloorAction = new flux
    .Action();
final flux.Action<Room> selectRoomAction = new flux.Action();
final flux.Action<Service> selectServiceAction = new flux.Action();
