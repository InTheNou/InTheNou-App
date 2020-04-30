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
  Future<List<Building>> _buildingsResults;
  Future<List<Room>> _roomsInBuilding;
  Future<List<Room>> _roomsResults;
  Future<List<Service>> _servicesResults;

  Building _selectedBuilding;
  Floor _selectedFloor;
  Room _selectedRoom;
  Service _selectedService;

  Future<Building> _detailBuilding;
  Future<Room> _detailRoom;
  Future<Service> _detailService;

  bool _isBuildingSearching = false;
  bool _isRoomSearching = false;
  bool _isServiceSearching = false;

  String _buildingSearchKeyword;
  String _roomSearchKeyword;
  String _serviceSearchKeyword;

  InfoBaseRepo _infoBaseRepo = new InfoBaseRepo();

  InfoBaseStore() {
    triggerOnAction(searchInfoBaseAction, (MapEntry<InfoBaseType, String> search) {
      switch (search.key) {
        case InfoBaseType.Building:
          _buildingSearchKeyword = search.value;
          _buildingsResults = _infoBaseRepo.searchBuildings(search.value,0, PAGINATION_LENGTH);
          break;
        case InfoBaseType.Room:
          _roomSearchKeyword = search.value;
          _searchRooms(search.value);
          break;
        case InfoBaseType.Service:
          _serviceSearchKeyword = search.value;
          _servicesResults = _infoBaseRepo.searchServices(search.value, 0, PAGINATION_LENGTH);
          break;
      }
    });
    triggerOnAction(setSearchingAction, (MapEntry<InfoBaseType, bool> searching) {
      switch (searching.key) {
        case InfoBaseType.Building:
          _isBuildingSearching = searching.value;
          break;
        case InfoBaseType.Room:
          _isRoomSearching = searching.value;
          break;
        case InfoBaseType.Service:
          _isServiceSearching = searching.value;
          break;
      }
    });
    triggerOnAction(reloadSearch, (InfoBaseType type) {
      switch (type) {
        case InfoBaseType.Building:
          _buildingsResults = _infoBaseRepo.searchBuildings(
              _buildingSearchKeyword,0, PAGINATION_LENGTH);
          break;
        case InfoBaseType.Room:
          _searchRooms(_roomSearchKeyword);
          break;
        case InfoBaseType.Service:
          _servicesResults = _infoBaseRepo.searchServices(
              _serviceSearchKeyword, 0, PAGINATION_LENGTH);
          break;
      }
    });
    triggerOnAction(clearInfoBaseKeywordAction, (InfoBaseType searching) {
      switch (searching) {
        case InfoBaseType.Building:
          _buildingSearchKeyword = "";
          break;
        case InfoBaseType.Room:
          _roomSearchKeyword = "";
          break;
        case InfoBaseType.Service:
          _serviceSearchKeyword = "";
          break;
      }
    });
    triggerOnAction(getAllBuildingsAction, (_) {
      _buildingsResults = _infoBaseRepo.getAllBuildings();
    });

    triggerOnAction(selectBuildingAction, (Building building) async {
      var dBuilding;
      try{
        dBuilding = await _detailBuilding;
      }catch(e){}
      if (dBuilding != null && building == dBuilding ) {
        return;
      }
      _detailRoom = null;
      _selectedFloor = null;
      _selectedBuilding = building;
      trigger();
      _detailBuilding = _infoBaseRepo.getBuilding(building.UID);
    });
    triggerOnAction(selectFloorAction, (MapEntry<Building, Floor> floor) async {
      var dRooms;
      try{
        dRooms = await _roomsInBuilding;
      }catch(e){}
      if (dRooms != null && _selectedFloor == floor.value) {
        return;
      }
      _roomsInBuilding = null;
      _selectedFloor = floor.value;
      trigger();
      _roomsInBuilding = _infoBaseRepo.getRoomsOfFloor(floor.key.UID,
          floor.value.floorNumber);
    });
    triggerOnAction(selectRoomAction, (Room room) async {
      var dRoom;
      try{
        dRoom = await _detailRoom;
      }catch(e){}
      if (dRoom != null && room == dRoom ) {
        return;
      }
      _detailRoom = null;
      _selectedRoom = room;
      trigger();
      _detailRoom = _infoBaseRepo.getRoom(room.UID);
    });
    triggerOnAction(selectServiceAction, (Service service) async {
      var dService;
      try{
        dService = await _detailService;
      }catch(e){}
      if (dService != null && service == dService ) {
        return;
      }
      _detailService = null;
      _selectedService = service;
      trigger();
      _detailService = _infoBaseRepo.getService(service.UID);
    });
  }

  void _searchRooms(String code){
    if(code.contains(RegExp(r"^\b[a-zA-Z]{1,2}-\d{1,3}[a-zA-Z]?$"))){
      var codeQuery = RegExp(
          r"(?<abrev>\b[a-zA-Z]{1,2})(?<dash>-)(?<code>\d{1,3}[a-zA-Z]?)")
          .firstMatch(code);
      String abrev = codeQuery.namedGroup("abrev");
      String rCode = codeQuery.namedGroup("code");
      _roomsResults = _infoBaseRepo.searchRoomsByCode(abrev, rCode, 0, PAGINATION_LENGTH);
    }
    else{
      _roomsResults = _infoBaseRepo.searchRoomsByKeyword(code, 0, PAGINATION_LENGTH);
    }
  }

  Future<List<Building>> get buildingsResults => _buildingsResults;
  Future<List<Room>> get roomsInBuilding => _roomsInBuilding;
  Future<List<Room>> get roomsResults => _roomsResults;
  Future<List<Service>> get servicesResults => _servicesResults;
  Building get selectedBuilding => _selectedBuilding;
  Floor get selectedFloor => _selectedFloor;
  Room get selectedRoom => _selectedRoom;
  Service get selectedService => _selectedService;
  Future<Building> get detailBuilding => _detailBuilding;
  Future<Room> get detailRoom => _detailRoom;
  Future<Service> get detailService => _detailService;

  bool getIsSearching(InfoBaseType type){
    switch(type){
      case InfoBaseType.Building:
        return _isBuildingSearching;
      case InfoBaseType.Room:
        return _isRoomSearching;
      case InfoBaseType.Service:
        return _isServiceSearching;
    }
    return false;
  }
  String getSearchKeyword(InfoBaseType type){
    switch(type){
      case InfoBaseType.Building:
        return _buildingSearchKeyword;
      case InfoBaseType.Room:
        return _roomSearchKeyword;
      case InfoBaseType.Service:
        return _serviceSearchKeyword;
    }
    return null;
  }

}

final flux.Action<MapEntry<InfoBaseType, String>> searchInfoBaseAction = new
  flux.Action();
final flux.Action<MapEntry<InfoBaseType, bool>> setSearchingAction = new
  flux.Action();
final flux.Action<InfoBaseType> reloadSearch = new flux.Action();
final flux.Action<InfoBaseType> clearInfoBaseKeywordAction = new flux.Action();
final flux.Action getAllBuildingsAction = new flux.Action();
final flux.Action<Building> selectBuildingAction = new flux.Action();
final flux.Action<MapEntry<Building,Floor>> selectFloorAction = new flux
    .Action();
final flux.Action<Room> selectRoomAction = new flux.Action();
final flux.Action<Service> selectServiceAction = new flux.Action();
