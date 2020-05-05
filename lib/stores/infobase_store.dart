import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
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

  bool _isBuildingPaginating = false;
  bool _isRoomPaginating = false;
  bool _isServicePaginating = false;

  bool _canBuildingPaginate = false;
  bool _canRoomPaginate = false;
  bool _canServicePaginate = false;

  String _buildingSearchKeyword;
  String _roomSearchKeyword;
  String _serviceSearchKeyword;

  InfoBaseRepo _infoBaseRepo = new InfoBaseRepo();

  DialogService _dialogService = DialogService();

  InfoBaseStore() {
    triggerOnAction(searchInfoBaseAction, (MapEntry<InfoBaseType, String>
        search) async{
      switch (search.key) {
        case InfoBaseType.Building:
          _buildingSearchKeyword = search.value;
          _buildingsResults = _searchBuildings(search.value,0, null);
          break;
        case InfoBaseType.Room:
          _roomSearchKeyword = search.value;
          _roomsResults = _searchRooms(search.value,0, null);
          break;
        case InfoBaseType.Service:
          _serviceSearchKeyword = search.value;
          _servicesResults = _searchServices(search.value, 0, null);
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
    triggerOnAction(reloadSearchAction, (InfoBaseType type) async{
      switch (type) {
        case InfoBaseType.Building:
          _isBuildingPaginating = false;
          if(_buildingSearchKeyword == null || _buildingSearchKeyword.isEmpty){
            _buildingsResults = _getAllBuildings(0, null);
          } else {
            _buildingsResults = _searchBuildings(_buildingSearchKeyword,0, null);
          }
          break;
        case InfoBaseType.Room:
          _isRoomPaginating = false;
          _roomsResults = _searchRooms(_roomSearchKeyword,0, null);
          break;
        case InfoBaseType.Service:
          _isServicePaginating = false;
          _servicesResults = _searchServices(_serviceSearchKeyword, 0, null);
          break;
      }
    });
    triggerOnAction(paginateInfoBaseAction, (InfoBaseType type) async{
      switch (type) {
        case InfoBaseType.Building:
          List<Building> buildings = await _buildingsResults;
          _isBuildingPaginating = true;
          if(_buildingSearchKeyword == null || _buildingSearchKeyword.isEmpty){
            _buildingsResults = _getAllBuildings(buildings.length, buildings);
          } else {
            _buildingsResults = _searchBuildings(_buildingSearchKeyword,0,
                buildings);
          }
          break;
        case InfoBaseType.Room:
          if(_roomSearchKeyword.isNotEmpty){
            _isRoomPaginating = true;
            var rooms = await _roomsResults;
            _roomsResults = _searchRooms(_roomSearchKeyword, rooms.length,
                rooms);
          }
          break;
        case InfoBaseType.Service:
          if(_serviceSearchKeyword.isNotEmpty){
            _isRoomPaginating = true;
            var services = await _servicesResults;
            _servicesResults = _searchServices(_serviceSearchKeyword, services.length,
                services);
          }
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
      _buildingsResults = _getAllBuildings(0, null);
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

  Future<List<Building>> _getAllBuildings(int skipBuildings,
      List<Building> results){
    _buildingSearchKeyword = "";
    return _infoBaseRepo.getAllBuildings(skipBuildings,
        PAGINATION_LENGTH).then((newBuildings) {

      List<Building> buildings = results ?? List();
      if(buildings.length > 0){
        buildings.addAll(newBuildings);
      } else {
        buildings = newBuildings;
      }
      _canBuildingPaginate = newBuildings.length == PAGINATION_LENGTH;
      _isBuildingPaginating = false;
      return buildings;
    }).catchError((e){
      _dialogService.showDialog(
          type: DialogType.Error,
          title: "Getting Results ",
          description: e.toString());
      return null;
    });
  }

  Future<List<Building>> _searchBuildings(String keyword, int skipBuildings,
      List<Building> results){
    return _infoBaseRepo.searchBuildings(keyword, skipBuildings,
        PAGINATION_LENGTH).then((newBuildings) {

          List<Building> buildings = results ?? List();
          if(buildings.length > 0){
            buildings.addAll(newBuildings);
          } else {
            buildings = newBuildings;
          }
          _canBuildingPaginate = newBuildings.length == PAGINATION_LENGTH;
          _isBuildingPaginating = false;
          return buildings;
    }).catchError((e){
      _dialogService.showDialog(
          type: DialogType.Error,
          title: "Getting Search Results ",
          description: e.toString());
      return null;
    });
  }

  Future<List<Room>> _searchRooms(String code, int skipRooms, List<Room> results){
    if(code.contains(RegExp(r"^\b[a-zA-Z]{1,2}-\d{1,3}[a-zA-Z]?$"))){
      var codeQuery = RegExp(
          r"(?<abrev>\b[a-zA-Z]{1,2})(?<dash>-)(?<code>\d{1,3}[a-zA-Z]?)")
          .firstMatch(code);
      String abrev = codeQuery.namedGroup("abrev");
      String rCode = codeQuery.namedGroup("code");
      return _infoBaseRepo.searchRoomsByCode(abrev, rCode, skipRooms,
          PAGINATION_LENGTH).then((newRooms) async{
            List<Room> rooms = results ?? List();
            if(rooms.length > 0){
              rooms.addAll(newRooms);
            } else {
              rooms = newRooms;
            }
            _canRoomPaginate = newRooms.length == PAGINATION_LENGTH;
            _isRoomPaginating = false;
            return rooms;
      }).catchError((e){
        _dialogService.showDialog(
            type: DialogType.Error,
            title: "Getting Room Results ",
            description: e.toString());
        return null;
      });
    }
    else{
      return _infoBaseRepo.searchRoomsByKeyword(code, skipRooms,
          PAGINATION_LENGTH).then((newRooms) async{
        List<Room> rooms = results ?? List();
        if(rooms.length > 0){
          rooms.addAll(newRooms);
        } else {
          rooms = newRooms;
        }
        _canRoomPaginate = newRooms.length == PAGINATION_LENGTH;
        _isRoomPaginating = false;
        return rooms;
      }).catchError((e){
        _dialogService.showDialog(
            type: DialogType.Error,
            title: "Getting Room Results ",
            description: e.toString());
        return null;
      });
    }
  }

  Future<List<Service>> _searchServices(String keyword, int skipServices,
      List<Service> results){
    return _infoBaseRepo.searchServices(keyword, skipServices,
        6).then((newServices) {

      List<Service> services = results ?? List();
      if(services.length > 0){
        services.addAll(newServices);
      } else {
        services = newServices;
      }
      _canServicePaginate = newServices.length == PAGINATION_LENGTH;
      _isServicePaginating = false;
      return services;
    }).catchError((e){
      _dialogService.showDialog(
          type: DialogType.Error,
          title: "Getting Service Results ",
          description: e.toString());
      return null;
    });
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
  bool getIsPaginating(InfoBaseType type){
    switch(type){
      case InfoBaseType.Building:
        return _isBuildingPaginating;
      case InfoBaseType.Room:
        return _isRoomPaginating;
      case InfoBaseType.Service:
        return _isServicePaginating;
    }
    return false;
  }
  bool getCanPaginate(InfoBaseType type){
    switch(type){
      case InfoBaseType.Building:
        return _canBuildingPaginate;
      case InfoBaseType.Room:
        return _canRoomPaginate;
      case InfoBaseType.Service:
        return _canServicePaginate;
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
final flux.Action<InfoBaseType> reloadSearchAction = new flux.Action();
final flux.Action<InfoBaseType> paginateInfoBaseAction = new flux.Action();

final flux.Action<InfoBaseType> clearInfoBaseKeywordAction = new flux.Action();
final flux.Action getAllBuildingsAction = new flux.Action();
final flux.Action<Building> selectBuildingAction = new flux.Action();
final flux.Action<MapEntry<Building,Floor>> selectFloorAction = new flux
    .Action();
final flux.Action<Room> selectRoomAction = new flux.Action();
final flux.Action<Service> selectServiceAction = new flux.Action();
