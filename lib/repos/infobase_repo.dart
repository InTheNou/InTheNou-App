import 'dart:io';
import 'package:InTheNou/assets/utils.dart';
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
        +"/App/Buildings/offset=0/limit=1000").then((response) {
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
        return Utils.createError("Getting Buildings ",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
    });
  }
  Future<List<Building>> searchBuildings(String keyword) async{
    return client.get(API_URL
        +"/App/Rooms/searchstring=$keyword/offset=0/limit=10000").then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Building> buildingResults = List();
        List<dynamic> jsonResponse =
          convert.jsonDecode(response.body)["buildings"];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            buildingResults.add(Building.resultFromJson(element));
          });
        }
        return buildingResults;
      } else {
        return Utils.createError("Searching Buildings ",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
    });
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
        return Utils.createError("Getting Building ",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
    });
  }
  Future<List<Room>> getRoomsOfFloor(int buildingUID, int floor) async{
    return client.get(API_URL
        +"/App/Rooms/bid=$buildingUID/rfloor=$floor").then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Room> roomResults = new List();
        if(response.body != null){
          Building b = Building
              .resultFromJson(convert.jsonDecode(response.body)['building']);
          List jsonResponse = convert.jsonDecode(response.body)['rooms'];
          if(jsonResponse != null){
            jsonResponse.forEach((element) {
              roomResults.add(Room.fromJson(element, b));
            });
          }
        }
        return roomResults;
      } else {
        return Utils.createError("Searching Room ",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
    });
  }
  Future<List<Room>> searchRoomsByKeyword(String keyword) async{
    return client.get(API_URL
        +"/App/Rooms/searchstring=$keyword/offset=0/limit=10000").then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Room> roomsResult = List();
        List<dynamic> jsonResponse = convert.jsonDecode(response.body)["rooms"];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            Building b = Building.resultFromJson(element['building']);
            roomsResult.add(Room.fromJson(element, b));
          });
        }
        return roomsResult;
      } else {
        return Utils.createError("Searching Rooms ",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
    });
  }
  Future<List<Room>> searchRoomsByCode(String abrev, String code) async{
    return client.get(API_URL
        +"/App/Rooms/babbrev=$abrev/rcode=$code/offset=0/limit=10000")
        .then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Room> roomsResult = List();
        List<dynamic> jsonResponse = convert.jsonDecode(response.body)["rooms"];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            Building b = Building.resultFromJson(element['building']);
            roomsResult.add(Room.fromJson(element, b));
          });
        }
        return roomsResult;
      } else {
        return Utils.createError("Searching Rooms ",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
    });
  }
  Future<Room> getRoom(int roomUID) async{
    return client.get(API_URL
        +"/App/Rooms/rid=$roomUID").then((response) {
      if (response.statusCode == HttpStatus.ok) {
        Room roomResult;
        Map<String, dynamic> jsonResponse = convert.jsonDecode(response.body);
        if(jsonResponse != null){
          Building b = Building.resultFromJson(jsonResponse['building']);
          roomResult = Room.fromJson(jsonResponse, b);

          List servicesJson = convert.jsonDecode(response.body)['services'];
          List<Service> services = List();
          if(servicesJson != null){
            servicesJson.forEach((service) {
            services.add(Service.fromJson(service, roomResult));
            });
          }
          roomResult.services = services;
        }
        return roomResult;
      } else {
        return Utils.createError("Getting Room ",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
    });
  }
  Future<List<Service>> searchServices(String keyword) async{
    return client.get(API_URL
        +"/App/Services/searchstring=$keyword/offset=0/limit=10000")
        .then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Service> serviceResult = List();
        List<dynamic> jsonResponse = convert.jsonDecode(response.body)
        ["services"];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            Building b = Building.resultFromJson(element["room"]['building']);
            Room r = Room.fromJson(element["room"], b);
            serviceResult.add(Service.fromJson(element, r));
          });
        }
        return serviceResult;
      } else {
        return Utils.createError("Searching Services ",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
    });
  }

  Future<Service> getService(int serviceUID){
    return client.get(API_URL
        +"/App/Services/sid=$serviceUID").then((response) {
      if (response.statusCode == HttpStatus.ok) {
        Room roomResult;
        Service service;
        Map<String, dynamic> jsonResponse = convert.jsonDecode(response.body);
        if(jsonResponse != null){
          Building b = Building.resultFromJson
            (jsonResponse['room']['building']);
          roomResult = Room.fromJson(jsonResponse["room"], b);

          Map<String,dynamic> servicesJson =
            convert.jsonDecode(response.body);

          if(servicesJson != null){
            service = Service.fromJson(servicesJson, roomResult);
          }
        }
        return service;
      } else {
        return Utils.createError("Getting Service ",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
    });
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