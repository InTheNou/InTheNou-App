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

  List<String> _errors = List(4);

  InfoBaseRepo _infoBaseRepo = new InfoBaseRepo();

  InfoBaseStore() {
    triggerOnConditionalAction(searchInfoBaseAction,
        (MapEntry<InfoBaseSearchType, String> search) {
      switch(search.key){
        case InfoBaseSearchType.Building:
          _buildingSearchKeyword = search.value;
          return _infoBaseRepo.searchBuildings(search.value).then((value) {
            _buildingsResults = value;
            return true;
          }).catchError((error){
            _setError(InfoBaseSearchType.Building, error.toString());
            return true;
          });
          break;
        case InfoBaseSearchType.Room:
          _roomSearchKeyword = search.value;
          return _searchRooms(search.value)
              .catchError((error){
                _setError(InfoBaseSearchType.Room, error.toString());
                return true;
              });
          break;
        case InfoBaseSearchType.Service:
          _serviceSearchKeyword = search.value;
          return _searchServicesByKeyword(search.value)
              .catchError((error){
                _setError(InfoBaseSearchType.Service, error.toString());
                return true;
              });
          break;
        default:
            return true;
          break;
      }
    });
    triggerOnAction(setSearchingAction,
            (MapEntry<InfoBaseSearchType, bool> searching) {
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
        case InfoBaseSearchType.Floor:
          break;
      }

    });
    triggerOnAction(clearInfoBaseKeywordAction, (InfoBaseSearchType searching) {
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
                case InfoBaseSearchType.Floor:
                  break;
              }
    });
    triggerOnConditionalAction(getAllBuildingsAction, (_) {
      return _infoBaseRepo.getAllBuildings().then((buildings){
        _buildingsResults = buildings;
        return true;
      }).catchError((error){
        _setError(InfoBaseSearchType.Building, error.toString());
        return true;
      });
    });

    triggerOnConditionalAction(selectBuildingAction, (Building building) {
      if(_detailBuilding == building){
        return false;
      }
      _detailRoom = null;
      trigger();
      return _infoBaseRepo.getBuilding(building.UID).then((value) {
        _detailBuilding = value;
        return true;
      }).catchError((error){
        _setError(InfoBaseSearchType.Building, error.toString());
        return true;
      });
    });
    triggerOnConditionalAction(selectFloorAction,
            (MapEntry<Building,Floor> floor) {
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
      }).catchError((error){
        _setError(InfoBaseSearchType.Floor, error.toString());
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
      }).catchError((error){
        _setError(InfoBaseSearchType.Room, error.toString());
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
      }).catchError((error){
        _setError(InfoBaseSearchType.Service, error.toString());
        return true;
      });
    });
    triggerOnAction(clearInfoBaseErrorAction, (InfoBaseSearchType type){
      switch (type){
        case InfoBaseSearchType.Building:
          _errors[0] = null;
          break;
        case InfoBaseSearchType.Room:
          _errors[1] = null;
          break;
        case InfoBaseSearchType.Service:
          _errors[2] = null;
          break;
        case InfoBaseSearchType.Floor:
          _errors[3] = null;
          break;
      }
    });
  }

  Future<bool> _searchRooms(String code){
    if(code.contains(RegExp(r"^\b[a-zA-Z]{1,2}-\d{1,3}[a-zA-Z]?$"))){
      var codeQuery = RegExp(
          r"(?<abrev>\b[a-zA-Z]{1,2})(?<dash>-)(?<code>\d{1,3}[a-zA-Z]?)")
          .firstMatch(code);
      String abrev = codeQuery.namedGroup("abrev");
      String rCode = codeQuery.namedGroup("code");
      return _infoBaseRepo.searchRoomsByCode(abrev, rCode).then((value){
        _roomsResults = value;
        return true;
      });
    }
    else{
      return _infoBaseRepo.searchRoomsByKeyword(code).then((value){
        _roomsResults = value;
        return true;
      });
    }
  }

  Future<bool> _searchServicesByKeyword(String code){
    return _infoBaseRepo.searchServices(code).then((value){
      _servicesResults = value;
      return true;
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
      case InfoBaseSearchType.Floor:
        break;
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
      case InfoBaseSearchType.Floor:
        break;
    }
    return null;
  }

  String getError(InfoBaseSearchType type){
    switch (type){
      case InfoBaseSearchType.Building:
        return _errors[0];
        break;
      case InfoBaseSearchType.Room:
        return _errors[1];
        break;
      case InfoBaseSearchType.Service:
        return _errors[2];
        break;
      case InfoBaseSearchType.Floor:
        return _errors[3];
        break;
      default:
        return null;
        break;
    }
  }

  void _setError(InfoBaseSearchType type, String error){
    switch (type){
      case InfoBaseSearchType.Building:
        _errors[0] = error;
        break;
      case InfoBaseSearchType.Room:
        _errors[1] = error;
        break;
      case InfoBaseSearchType.Service:
        _errors[2] = error;
        break;
      case InfoBaseSearchType.Floor:
        _errors[3] = error;
        break;
    }
  }

}

final flux.Action<MapEntry<InfoBaseSearchType, String>> searchInfoBaseAction = new
  flux.Action();
final flux.Action<MapEntry<InfoBaseSearchType, bool>> setSearchingAction = new
  flux.Action();
final flux.Action<InfoBaseSearchType> clearInfoBaseKeywordAction = new
  flux.Action();
final flux.Action<InfoBaseSearchType> clearInfoBaseErrorAction = new
flux.Action();
final flux.Action getAllBuildingsAction = new flux.Action();
final flux.Action<Building> selectBuildingAction = new flux.Action();
final flux.Action<MapEntry<Building,Floor>> selectFloorAction = new flux
    .Action();
final flux.Action<Room> selectRoomAction = new flux.Action();
final flux.Action<Service> selectServiceAction = new flux.Action();
