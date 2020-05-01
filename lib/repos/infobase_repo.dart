import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// {@category Repo}
class InfoBaseRepo {

  static final InfoBaseRepo _instance = InfoBaseRepo._internal();
  final ApiConnection apiConnection = ApiConnection();

  factory InfoBaseRepo() {
    return _instance;
  }

  InfoBaseRepo._internal();

  /// Calls the back-end to get all the [Building]s in the system
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Building>> getAllBuildings() async{
    try{
      Response response = await apiConnection.dio.get("/App/Buildings/offset=0/limit=1000");
      List<Building> buildingResults = new List();

      if(response.data != null){
        response.data.forEach((element) {
          buildingResults.add(Building.fromJson(element));
        });
      }
      return buildingResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting Buildings") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Buildings");
      }
    }
  }

  /// Calls the back-end with a search query for the [Building]s
  ///
  /// The method returns all Buildings in the system that match the [keyword]
  /// in their [Building._name] or [Building._commonName]. The parameter
  /// [skipBuildings] can be supplied to let the back-end know the first
  /// Building that needs to be returned, this along with [numBuildings] permits
  /// performing pagination and only showing a few Buildings at a time.
  /// To get all the Buildings at once just supply a very big number to
  /// [numBuildings].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Building>> searchBuildings(String keyword, int skipBuildings,
      int numBuildings) async{
    try{
      Response response = await apiConnection.dio.get("/App/Buildings/Search/searchstring="
          "$keyword/offset=$skipBuildings/limit=$numBuildings");
      List<Building> buildingResults = new List();

      if(response.data != null){
        response.data.forEach((element) {
          buildingResults.add(Building.fromJson(element));
        });
      }
      return buildingResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Searching "
            "Buildings") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Searching Buildings");
      }
    }
  }

  /// Calls the back-end to get all the information on a specific [Building].
  ///
  /// Given the [Building._UID] through the [buildingUID] parameter, the back-end
  /// will return detailed information about the [Building] that matches the UID.
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<Building> getBuilding(int buildingUID) async{
    try{
      Response response = await apiConnection.dio.get("/App/Buildings/bid=$buildingUID");
      Building buildingResult;

      if(response.data != null){
        buildingResult =  Building.fromJson(response.data);
      }
      return buildingResult;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting Building") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Building");
      }
    }
  }

  /// Calls the back-end to get all the [Building]s in a [Floor]
  ///
  /// Given a [Building._UID] through [buildingUID] and a
  /// [Floor._floorNumber]  through [floor] a list of [Room]s will be returned.
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Room>> getRoomsOfFloor(int buildingUID, int floor) async{
    try{
      Response response = await apiConnection.dio.get("/App/Rooms/bid=$buildingUID/rfloor=$floor");
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
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting Rooms in "
            "Floor") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Rooms in Floor");
      }
    }
  }

  /// Calls the back-end with a search query for the [Room]s
  ///
  /// The method returns all Rooms in the system that match the [keyword]
  /// in their [Room._description]. The parameter
  /// [skipRooms] can be supplied to let the back-end know the first
  /// Room that needs to be returned, this along with [numRooms] permits
  /// performing pagination and only showing a few Rooms at a time.
  /// To get all the Rooms at once just supply a very big number to
  /// [numRooms].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Room>> searchRoomsByKeyword(String keyword, int skipRooms,
      int numRooms) async{
    try{
      Response response = await apiConnection.dio.get("/App/Rooms/searchstring=$keyword/"
          "offset=$skipRooms/limit=$numRooms");
      List<Room> roomResults = new List();

      if(response.data != null){
        if(response.data["rooms"] != null){
          response.data["rooms"].forEach((element) {
            Building b = Building.resultFromJson(element['building']);
            roomResults.add(Room.fromJson(element, b));
          });
        }
      }
      return roomResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Searching Rooms by "
            "keyword") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Searching Rooms by keyword");
      }
    }
  }

  /// Calls the back-end with a search query for the [Room]s
  ///
  /// The method returns all Rooms in the system that match the [abrev] in
  /// their associated [Building._abbreviation] and [code] in their
  /// [Room._code]. The parameter [skipRooms] can be supplied to let the
  /// back-end know the first
  /// Room that needs to be returned, this along with [numRooms] permits
  /// performing pagination and only showing a few Rooms at a time.
  /// To get all the Rooms at once just supply a very big number to
  /// [numRooms].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Room>> searchRoomsByCode(String abrev, String code, int skipRooms,
      int numRooms) async{
    try{
      Response response = await apiConnection.dio.get("/App/Rooms/babbrev=$abrev/"
          "rcode=$code/offset=$skipRooms/limit=$numRooms");
      List<Room> roomResults = new List();

      if(response.data != null){
        if(response.data["rooms"] != null){
          response.data["rooms"].forEach((element) {
            Building b = Building.resultFromJson(element['building']);
            roomResults.add(Room.fromJson(element, b));
          });
        }
      }
      return roomResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Searching Rooms by "
            "Code") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Searching Rooms by Code");
      }
    }
  }

  /// Calls the back-end to get all the information on a specific [Room].
  ///
  /// Given the [Room._UID] through the [roomUID] parameter, the back-end
  /// will return detailed information about the [Room] that matches the UID.
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<Room> getRoom(int roomUID) async{
    try{
      Response response = await apiConnection.dio.get("/App/Rooms/rid=$roomUID");
      Room roomResult;

      if(response.data != null){
        Building b = Building.resultFromJson(response.data['building']);
        roomResult = Room.fromJson(response.data, b);

        List<Service> services = List();
        if(response.data['services'] != null){
          response.data['services'].forEach((service) {
            services.add(Service.fromJson(service, roomResult));
          });
        }
        roomResult.services = services;
      }
      return roomResult;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting Room") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Room");
      }
    }
  }

  /// Calls the back-end with a search query for the [Service]s
  ///
  /// The method returns all Services in the system that match the [keyword]
  /// in their [Service._name] or [Service._description]. The parameter
  /// [skipServices] can be supplied to let the back-end know the first
  /// Service that needs to be returned, this along with [numServices] permits
  /// performing pagination and only showing a few Rooms at a time.
  /// To get all the Services at once just supply a very big number to
  /// [numServices].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Service>> searchServices(String keyword, int skipServices,
      int numServices) async{
    try{
      Response response = await apiConnection.dio.get("/App/Services/searchstring=$keyword/"
          "offset=$skipServices/limit=$numServices");
      List<Service> serviceResult = List();

      if(response.data['services'] != null){
        response.data['services'].forEach((element) {
          Building b = Building.resultFromJson(element["room"]['building']);
          Room r = Room.fromJson(element["room"], b);
          serviceResult.add(Service.fromJson(element, r));
        });
      }
      return serviceResult;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Searching Services") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Searching Services");
      }
    }
  }

  /// Calls the back-end to get all the information on a specific [Service].
  ///
  /// Given the [Service._UID] through the [serviceUID] parameter, the back-end
  /// will return detailed information about the [Service] that matches the UID.
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<Service> getService(int serviceUID) async{
    try{
      Response response = await apiConnection.dio.get("/App/Services/sid=$serviceUID");
      Room roomResult;
      Service service;

      if(response.data != null){
        Building b = Building.resultFromJson
          (response.data['room']['building']);
        roomResult = Room.fromJson(response.data["room"], b);
        service = Service.fromJson(response.data, roomResult);
      }
      return service;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting Service") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Service");
      }
    }
  }
}