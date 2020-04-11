import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/models/phone_number.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class InfoBaseRepo {

  static final InfoBaseRepo _instance = InfoBaseRepo._internal();
  var client = http.Client();
  final ApiConnection apiConnection = ApiConnection();
  Dio dio;

  factory InfoBaseRepo() {
    return _instance;
  }

  InfoBaseRepo._internal(){
    dio = apiConnection.dio;
  }

  Future<List<Building>> getAllBuildings() async{
    try{
      Response response = await dio.get("/App/Buildings/offset=0/limit=1000");
      List<Building> buildingResults = new List();
      List jsonResponse = response.data;
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          buildingResults.add(Building.fromJson(element));
        });
      }
      return buildingResults;
    } catch(e){
      if (e is DioError) {
        return Future.error(Utils.handleDioError(e, "Getting Buildings") );
      } else {
        return Future.error("Internal app error Getting Buildings");
      }
    }
  }
  Future<List<Building>> searchBuildings(String keyword) async{
    try{
      Response response = await dio.get("/App/Buildings/Search/searchstring="
          "$keyword/offset=0/limit=10000");
      List<Building> buildingResults = new List();
      List jsonResponse = response.data;
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          buildingResults.add(Building.fromJson(element));
        });
      }
      return buildingResults;
    } catch(e){
      if (e is DioError) {
        return Future.error(Utils.handleDioError(e, "Searching Buildings") );
      } else {
        return Future.error("Internal app error Searching Buildings");
      }
    }
  }
  Future<Building> getBuilding(int buildingUID) async{
    try{
      Response response = await dio.get("/App/Buildings/bid=$buildingUID");
      Building buildingResult;
      Map<String, dynamic> jsonResponse = response.data;
      if(jsonResponse != null){
        buildingResult =  Building.fromJson(jsonResponse);
      }
      return buildingResult;
    } catch(e){
      if (e is DioError) {
        return Future.error(Utils.handleDioError(e, "Getting Building") );
      } else {
        return Future.error("Internal app error Getting Building");
      }
    }
  }
  Future<List<Room>> getRoomsOfFloor(int buildingUID, int floor) async{
    try{
      Response response = await dio.get("/App/Rooms/bid=$buildingUID/rfloor=$floor");
      List<Room> roomResults = new List();
      if(response.data != null){
        Building b = Building
            .resultFromJson(response.data['building']);
        List jsonResponse = response.data['rooms'];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            roomResults.add(Room.fromJson(element, b));
          });
        }
      }
      return roomResults;
    } catch(e){
      if (e is DioError) {
        return Future.error(Utils.handleDioError(e, "Getting Rooms in Floor") );
      } else {
        return Future.error("Internal app error Getting Rooms in Floor");
      }
    }
  }
  Future<List<Room>> searchRoomsByKeyword(String keyword) async{
    try{
      Response response = await dio.get("/App/Rooms/searchstring=$keyword/"
          "offset=0/limit=10000");
      List<Room> roomResults = new List();
      print(response.data);
      if(response.data != null){
        List<dynamic> jsonResponse = response.data["rooms"];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            Building b = Building.resultFromJson(element['building']);
            roomResults.add(Room.fromJson(element, b));
          });
        }
      }
      return roomResults;
    } catch(e){
      if (e is DioError) {
        return Future.error(Utils.handleDioError(e, "Searching Rooms by "
            "keyword") );
      } else {
        return Future.error("Internal app error Searching Rooms by keyword");
      }
    }
  }
  Future<List<Room>> searchRoomsByCode(String abrev, String code) async{
    try{
      Response response = await dio.get("/App/Rooms/babbrev=$abrev/"
          "rcode=$code/offset=0/limit=10000");
      List<Room> roomResults = new List();
      if(response.data != null){
        List<dynamic> jsonResponse = response.data["rooms"];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            Building b = Building.resultFromJson(element['building']);
            roomResults.add(Room.fromJson(element, b));
          });
        }
      }
      return roomResults;
    } catch(e){
      if (e is DioError) {
        return Future.error(Utils.handleDioError(e, "Searching Rooms by "
            "Code") );
      } else {
        return Future.error("Internal app error Searching Rooms by Code");
      }
    }
  }
  Future<Room> getRoom(int roomUID) async{
    try{
      Response response = await dio.get("/App/Rooms/rid=$roomUID");
      Room roomResult;
      Map<String, dynamic> jsonResponse = response.data;
      if(jsonResponse != null){
        Building b = Building.resultFromJson(jsonResponse['building']);
        roomResult = Room.fromJson(jsonResponse, b);

        List servicesJson = response.data['services'];
        List<Service> services = List();
        if(servicesJson != null){
          servicesJson.forEach((service) {
            services.add(Service.fromJson(service, roomResult));
          });
        }
        roomResult.services = services;
      }
      return roomResult;
    } catch(e){
      if (e is DioError) {
        return Future.error(Utils.handleDioError(e, "Getting Room") );
      } else {
        return Future.error("Internal app error Getting Room");
      }
    }
  }
  Future<List<Service>> searchServices(String keyword) async{
    try{
      Response response = await dio.get("/App/Services/searchstring=$keyword/"
          "offset=0/limit=10000");
      List<Service> serviceResult = List();
      List<dynamic> jsonResponse = response.data["services"];
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          Building b = Building.resultFromJson(element["room"]['building']);
          Room r = Room.fromJson(element["room"], b);
          serviceResult.add(Service.fromJson(element, r));
        });
      }
      return serviceResult;
    } catch(e){
      if (e is DioError) {
        return Future.error(Utils.handleDioError(e, "Searching Services") );
      } else {
        return Future.error("Internal app error Searching Services");
      }
    }
  }

  Future<Service> getService(int serviceUID) async{
    try{
      Response response = await dio.get("/App/Services/sid=$serviceUID");
      Room roomResult;
      Service service;
      Map<String, dynamic> jsonResponse = response.data;
      if(jsonResponse != null){
        Building b = Building.resultFromJson
          (jsonResponse['room']['building']);
        roomResult = Room.fromJson(jsonResponse["room"], b);
        if(jsonResponse != null){
          service = Service.fromJson(jsonResponse, roomResult);
          print(service.schedule);
        }
      }
      return service;
    } catch(e){
      if (e is DioError) {
        return Future.error(Utils.handleDioError(e, "Getting Service") );
      } else {
        return Future.error("Internal app error Getting Service");
      }
    }
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