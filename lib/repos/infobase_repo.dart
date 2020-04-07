import 'dart:io';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/models/phone_number.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/models/website.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class InfoBaseRepo {

  static final InfoBaseRepo _instance = InfoBaseRepo._internal();
  var client = http.Client();

  factory InfoBaseRepo() {
    return _instance;
  }

  InfoBaseRepo._internal();

  Future<List<Building>> getAllBuildings() async{
    return client.get(API_URL
        +"/App/Buildings/offset=0/limit=1000")
        .then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Building> buildingResults = new List();
        List jsonResponse = convert.jsonDecode(response.body);
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            buildingResults.add(Building.fromJson(element));
          });
        }
        return buildingResults;
      } else {
        return Future.error("Request failed with status: ${response
            .statusCode} please try again");
      }
    });
//    return new List.from(dummyBuildings);
  }
  List<Building> searchBuildings(String keyword){
    runLocalBuildingSearch(keyword);
    return new List.from(buildingsSearch);
  }
  Future<Building> getBuilding(int buildingUID) async{
    return client.get(API_URL
        +"/App/Buildings/bid=$buildingUID").then((response) {
      if (response.statusCode == HttpStatus.ok) {
        Building buildingResult;
        Map<String, dynamic> jsonResponse = convert.jsonDecode(response.body);
        if(jsonResponse != null){
          buildingResult =  Building.fromJson(jsonResponse);
        }
        return buildingResult;
      } else {
        return Future.error("Request failed with status: ${response
            .statusCode} please try again");
      }
    });
//    return dummyBuildings.firstWhere((element) => (element.UID ==
//        buildingUID));
  }
  Future<List<Room>> getRoomsOfFloor(int buildingUID, int floor) async{
    return client.get(API_URL
        +"/App/Rooms/bid=$buildingUID/rfloor=$floor").then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Room> roomResults = new List();
        Building b = Building
            .resultFromJson(convert.jsonDecode(response.body)['building']);
        List jsonResponse = convert.jsonDecode(response.body)['rooms'];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            roomResults.add(Room.fromJson(element, b));
          });
        }
        return roomResults;
      } else {
        return Future.error("Request failed with status: ${response
            .statusCode} please try again");
      }
    });
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
          (index) => new Building(index, "B$index","Building $index",
              "Cool Building $index",
              2,List.generate(2, (i) => Floor.fromJson(i)), "academic", new
              Coordinate(18.209641, -67.139923,0),
              "https://pbs.twimg.com/media/DN8sEJpUEAAyuyF?format=jpg&name=large"));

  var dummyRooms = <int,List<Room>>{
      0: new List.generate(20,(index) =>
        new Room(index, "S-"+(index%2).toString()+"$index", "Building 0",
            (index%2), "nice room", 20, "email@upr.edu",
            new Coordinate(18.209641, -67.139923,0))),
      1: new List.generate(20,(index) =>
      new Room(index+100, "S-"+(index%2).toString()+"$index", "Building 0",
          (index%2), "nice room", 20, "email@upr.edu",
          new Coordinate(18.209641, -67.139923,0))),
  };

  var dummyServices = <int,List<Service>>{
    0: new List.generate(20,(index) =>
    new Service(index,"Service B0 $index", "Nice service inside B0",
        "S-"+(index%2).toString()+"$index", "Schedule $index \nSchedule $index",
        [PhoneNumber("787-123-4567,1234", PhoneType.E),
          PhoneNumber("787-123-4567", PhoneType.F)],
        new List<Website>.filled(2,
            new Website("https://portal.upr.edu/rum/portal.php?a=rea_login",
                "Portal"))
    )),
    1: new List.generate(20,(index) =>
    new Service(index+100,"Service B1 $index", "Nice service inside B1",
      "S-"+(index%2).toString()+"$index", "Schedule $index \nSchedule $index",
      [PhoneNumber("787-123-4567,1234", PhoneType.E),
        PhoneNumber("787-123-4567", PhoneType.L)],
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