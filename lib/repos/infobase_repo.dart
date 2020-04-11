import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class InfoBaseRepo {

  static final InfoBaseRepo _instance = InfoBaseRepo._internal();
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
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Getting Buildings") );
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
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Searching "
            "Buildings") );
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
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Getting Building") );
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
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Getting Rooms in "
            "Floor") );
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
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Searching Rooms by "
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
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Searching Rooms by "
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
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Getting Room") );
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
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Searching Services") );
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
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Getting Service") );
      } else {
        return Future.error("Internal app error Getting Service");
      }
    }
  }
}