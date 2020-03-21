import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/phone_number.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/models/website.dart';

class InfoBaseRepo {

  static final InfoBaseRepo _instance = InfoBaseRepo._internal();

  factory InfoBaseRepo() {
    return _instance;
  }

  InfoBaseRepo._internal();

  List<Building> getAllBuildings(){
    return new List.from(dummyBuildings);
  }
  List<Building> searchBuildings(String keyword){
    runLocalBuildingSearch(keyword);
    return new List.from(buildingsSearch);
  }
  Building getBuilding(int buildingUID){
    return dummyBuildings.firstWhere((element) => (element.UID ==
        buildingUID));
  }
  List<Room> getRoomsOfFloor(int buildingUID, int floor){
    return dummyRooms[buildingUID].where((element) => element.floor == floor-1)
        .toList();
  }
  List<Room> searchRooms(String keyword){
    runLocalRoomSearch(keyword);
    return new List.from(roomsSearch);
  }
  Room getRoom(int roomUID){
    return dummyRooms[0].firstWhere((element) => (element.UID == roomUID));
  }
  List<Service> searchServices(String keyword){
    runLocalServiceSearch(keyword);
    return new List.from(servicesSearch);
  }
  List<Service> getServicesOfRoom(int roomUID){
    return dummyServices[0].where((service) => service.roomCode == "S-00")
        .toList();
  }
  Service getService(int serviceUID){
    return dummyServices[0].firstWhere((element) => element.UID == serviceUID);
  }

//---------------------- DEBUGGING STUFF ----------------------
  List<Building> dummyBuildings = new List.generate(2,
          (index) => new Building(index, "Building $index",
              "Cool Building $index",
              2, "academic", new Coordinate(18.209641, -67.139923)));

  var dummyRooms = <int,List<Room>>{
      0: new List.generate(20,(index) =>
        new Room(index, "S-"+(index%2).toString()+"$index", "Building 0",
            (index%2), "nice room", 20, "email@upr.edu",
            new Coordinate(18.209641, -67.139923))),
      1: new List.generate(20,(index) =>
      new Room(index+100, "S-"+(index%2).toString()+"$index", "Building 0",
          (index%2), "nice room", 20, "email@upr.edu",
          new Coordinate(18.209641, -67.139923))),
  };

  var dummyServices = <int,List<Service>>{
    0: new List.generate(20,(index) =>
    new Service(index,"Service B0 $index", "Nice service inside B0",
        "S-"+(index%2).toString()+"$index", new List.generate(2, (index) =>
        "Schedule $index "),
        [PhoneNumber("787-123-4567", PhoneType.E),
          PhoneNumber("787-123-4567", PhoneType.E)],
        new List<Website>.filled(2,
            new Website("https://portal.upr.edu/rum/portal.php?a=rea_login", "P"
                "ortal"))
    )),
    1: new List.generate(20,(index) =>
    new Service(index+100,"Service B1 $index", "Nice service inside B1",
      "S-"+(index%2).toString()+"$index", new List.generate(2, (index) =>
        "Schedule $index "),
      [PhoneNumber("787-123-4567", PhoneType.E),
        PhoneNumber("787-123-4567", PhoneType.E)],
      new List<Website>.filled(2,
          new Website("https://portal.upr.edu/rum/portal.php?a=rea_login", "P"
              "ortal"))
    ))
  };

  List<Building> buildingsSearch = new List();
  void runLocalBuildingSearch(String keyword){
    if (keyword.isNotEmpty) {
      buildingsSearch.clear();
      dummyBuildings.forEach((element) {
        if (element.name.contains(keyword)){
          buildingsSearch.add(element);
        } else if (element.commonName.contains(keyword)){
          buildingsSearch.add(element);
        }
      });
    }
  }
  List<Room> roomsSearch = new List();
  void runLocalRoomSearch(String keyword){
    if (keyword.isNotEmpty) {
      roomsSearch.clear();
      dummyRooms.entries.forEach((element) {
        element.value.forEach((room) {
          if (room.description.contains(keyword)){
            roomsSearch.add(room);
          } else if (room.code.contains(keyword)){
            roomsSearch.add(room);
          } else if (room.building.contains(keyword)){
            roomsSearch.add(room);
          }
        });
      });
    }
  }
  List<Service> servicesSearch = new List();
  void runLocalServiceSearch(String keyword){
    if (keyword.isNotEmpty) {
      servicesSearch.clear();
      dummyServices.entries.forEach((element) {
        element.value.forEach((service) {
          if (service.description.contains(keyword)){
            servicesSearch.add(service);
          } else if (service.name.contains(keyword)){
            servicesSearch.add(service);
          } else if (service.roomCode.contains(keyword)){
            servicesSearch.add(service);
          }
        });
      });
    }
  }
}