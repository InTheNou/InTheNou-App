import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';

class InfoBaseRepo {

  static final InfoBaseRepo _instance = InfoBaseRepo._internal();

  factory InfoBaseRepo() {
    return _instance;
  }

  InfoBaseRepo._internal();

  List<Building> getAllBuildings(){
    return new List.from(dummyBuildings);
  }
  Building getBuilding(int buildingUID){
    return dummyBuildings.firstWhere((element) => (element.UID == buildingUID));
  }
  List<Room> getRoomsOfFloor(int buildingUID, int floor){
    return dummyRooms[buildingUID].where((element) => element.floor == floor);
  }
  Room getRoom(int roomUID){
    return dummyRooms[0].firstWhere((element) => (element.UID == roomUID));
  }
  List<Service> getSErvicesOfRoom(int roomUID){

  }
  Service getService(int serviceUID){

  }

//---------------------- DEBUGGING STUFF ----------------------
  List<Building> dummyBuildings = new List.generate(2,
          (index) => new Building(index, "Building $index",
              "Cool Building $index",
              1, "academic", new Coordinate(18.209641, -67.139923)));

  var dummyRooms = <int,List<Room>>{
      0: new List.generate(9,(index) =>
        new Room(index, "S-$index", "Building 0",
            (index%2), "nice room", 20, "email@upr.edu",
            new Coordinate(18.209641, -67.139923))),
      1: new List.generate(9,(index) =>
      new Room(index, "S-$index", "Building 0",
          (index%2), "nice room", 20, "email@upr.edu",
          new Coordinate(18.209641, -67.139923))),
  };
}