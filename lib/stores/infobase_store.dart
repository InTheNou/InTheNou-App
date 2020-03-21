import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/repos/infobase_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class InfoBaseStore extends flux.Store{

  List<Building> _buildingsResults = new List();
  List<Room> _roomsInBuilding;
  List<Room> _roomsResults = new List();
  List<Service> _servicesInRoom = new List();
  List<Service> _servicesResults = new List();

  Building _detailBuilding;
  Room _detailRoom;
  Service _detailService;

  bool _isSearching = false;
  String _searchKeyword;

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
      _isSearching = searching.value;
    });
    triggerOnAction(clearInfoBaseKeywordAction,
            (InfoBaseSearchType searching){
              _searchKeyword = "";
    });
    triggerOnAction(getAllBuildingsAction, (_){
      _buildingsResults = _infoBaseRepo.getAllBuildings();
    });

    triggerOnAction(selectBuildingAction, (Building building){
      _detailBuilding = _infoBaseRepo.getBuilding(building.UID);
    });
    triggerOnAction(selectFloorAction, (MapEntry<Building,int> floor){
      _roomsInBuilding = _infoBaseRepo.getRoomsOfFloor(floor.key.UID,
          floor.value);
    });
    triggerOnAction(selectRoomAction, (Room room){
      _detailRoom = _infoBaseRepo.getRoom(room.UID);
      _servicesInRoom = _infoBaseRepo.getServicesOfRoom(room.UID);
    });
    triggerOnAction(selectServiceAction, (Service service){
      _detailService = _infoBaseRepo.getService(service.UID);
    });
  }

  List<Building> get buildingsResults => _buildingsResults;
  List<Room> get roomsInBuilding => _roomsInBuilding;
  List<Room> get roomsResults => _roomsResults;
  List<Service> get servicesInRoom => _servicesInRoom;
  List<Service> get servicesResults => _servicesResults;
  bool get isSearching => _isSearching;

  Building get detailBuilding => _detailBuilding;
  Room get detailRoom => _detailRoom;
  Service get detailService => _detailService;

}

final flux.Action<MapEntry<InfoBaseSearchType, String>> searchInfoBaseAction = new
  flux.Action();
final flux.Action<MapEntry<InfoBaseSearchType, bool>> setSearchingAction = new
  flux.Action();
final flux.Action<InfoBaseSearchType> clearInfoBaseKeywordAction = new
  flux.Action();

final flux.Action getAllBuildingsAction = new flux.Action();
final flux.Action<Building> selectBuildingAction = new flux.Action();
final flux.Action<MapEntry<Building,int>> selectFloorAction = new flux
    .Action();
final flux.Action<Room> selectRoomAction = new flux.Action();
final flux.Action<Service> selectServiceAction = new flux.Action();

final flux.StoreToken infoBaseToken = new flux.StoreToken(new InfoBaseStore());