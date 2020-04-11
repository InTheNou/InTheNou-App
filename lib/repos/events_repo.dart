import 'dart:math';
import 'dart:convert' as convert;
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsRepo {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static final EventsRepo _instance = EventsRepo._internal();
  final ApiConnection apiConnection = ApiConnection();
  Dio dio;

  Random rand = Random();

  factory EventsRepo() {
    return _instance;
  }

  EventsRepo._internal(){
    dio = apiConnection.dio;
  }

  /// Calls teh back-end to get the Events for the General Feed
  ///
  /// The method returns all active and non-dismissed Events in the system. The
  /// parameter [skipEvents] can be supplied to let the back-end know the
  /// first event that needs to be returned, this along with [numEvents]
  /// permits performing pagination and only showing a few Events at a time.
  /// To get all the Events at once just supply a very bit number to [numEvents]
  Future<List<Event>> getGenEvents (int skipEvents, int numEvents) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    try{
      Response response = await dio.get(
          "/App/Events/General/uid=${user.UID}/offset=$skipEvents"
              "/limit=$numEvents");
      List<Event> eventResults = new List();
      List jsonResponse = response.data["events"];
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          eventResults.add(Event.resultFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Getting General "
            "Events") );
      } else {
        return Future.error("Internal app error Getting General Events");
      }
    }
  }

  /// Calls teh back-end to get the Events for the Personal Feed.
  ///
  /// The method returns all active Recommended and non-dismissed [Event]s in
  /// the system. The parameter [skipEvents] can be supplied to let the
  /// back-end know the first event that needs to be returned, this along
  /// with [numEvents] permits performing pagination and only showing a few
  /// Events at a time.
  /// To get all the Events at once just supply a very bit number to
  /// [numEvents].
  Future<List<Event>> getPerEvents(int skipEvents, int numEvents) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    try{
      Response response = await dio.get(
          "/App/Events/Recommended/uid=${user.UID}/offset=$skipEvents/"
              "limit=$numEvents");
      List<Event> eventResults = new List();
      List jsonResponse = response.data["events"];
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          eventResults.add(Event.resultFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Getting Personal "
            "Events"));
      } else {
        return Future.error("Internal app error Getting Personal Events");
      }
    }
  }

  /// Contacts the back-end to get [Event]s created after [lastDate].
  ///
  /// The parameter [lastDate] is a DateTime object in String form, with the
  /// format yyyy-MM-dd hh:mm:ss.
  /// This method is used in the Recommendation Feature.
  Future<List<Event>> getNewEvents(String lastDate) async{
    DateTime date = DateTime.parse(lastDate);
    return new List.from(dummyEvents.where((event) =>
        event.startDateTime.isAfter(date)));
  }

  /// Calls the back-end with a search query for the General Feed
  ///
  /// The method returns all active and non-dismissed Events in the system
  /// that match the [keyword] in their [Event._title] or
  /// [Event._description]. The parameter [skipEvents] can be supplied to let the
  /// back-end know the first event that needs to be returned, this along
  /// with [numEvents] permits performing pagination and only showing a few
  /// Events at a time.
  /// To get all the Events at once just supply a very bit number to [numEvents]
  Future<List<Event>> searchGenEvents(String keyword, int skipEvents,
      int numEvents) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    try{
      Response response = await dio.get(
          "/App/Events/General/search=$keyword/offset=$skipEvents/limit=$numEvents"
              "/uid=${user.UID}");
      List<Event> eventResults = new List();
      List jsonResponse = response.data["events"];
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          eventResults.add(Event.resultFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Searching General "
            "Events"));
      } else {
        return Future.error("Internal app error Searching General Events");
      }
    }
  }

  /// Calls the back-end with a search query for the Personal Feed
  ///
  /// The method returns all Recommended and non-dismissed Events in the
  /// system that match the [keyword] in their [Event._title] or
  /// [Event._description]. The parameter [skipEvents] can be supplied to let
  /// the back-end know the first event that needs to be returned, this along
  /// with [numEvents] permits performing pagination and only showing a few
  /// Events at a time.
  /// To get all the Events at once just supply a very bit number to [numEvents]
  Future<List<Event>> searchPerEvents(String keyword, int skipEvents,
      int numEvents) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    try{
      Response response = await dio.get(
          "/App/Events/Recommended/search=$keyword/offset=$skipEvents/limit"
              "=$numEvents/uid=${user.UID}");
      List<Event> eventResults = new List();
      List jsonResponse = response.data["events"];
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          eventResults.add(Event.resultFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error,
            "Searching Personal Events"));
      } else {
        return Future.error("Internal app error Searching Personal Events");
      }
    }
  }

  /// Calls the back-end to get all the information on a specific [Event].
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// will return detailed information about the [Event] that matches the UID.
  Future<Event> getEvent(int eventUID) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    try{
      Response response = await dio.get("/App/Events/eid=$eventUID/"
          "uid=${user.UID}");
      return Event.fromJson(response.data);
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Getting Event"));
      } else {
        return Future.error("Internal app error while Getting Event");
      }
    }
  }

  /// Requests for an [Event] to be marked as Followed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being Followed by this user by setting [Event.followed]
  Future<bool> requestFollowEvent(int eventUID) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    try{
      Response response = await dio.post("/App/Events/eid=$eventUID/"
          "uid=${user.UID}/Follow");
      return response.data["event"]["eid"] == eventUID;
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Follow Event"));
      } else {
        return Future.error("Internal app error while Follwing Event");
      }
    }
  }

  /// Requests for an [Event] to be marked as UnFollowed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being UnFollowed by this user by setting [Event.followed]
  Future<bool> requestUnFollowEvent(int eventUID) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    try{
      Response response = await dio.post("/App/Events/eid=$eventUID/"
          "uid=${user.UID}/Unfollow");
      return response.data["event"]["eid"] == eventUID;
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "UnFollow Event"));
      } else {
        return Future.error("Internal app error while UnFollwing Event");
      }
    }
  }

  /// Requests for an [Event] to be marked as Dismissed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being Dismissed by this user. Events marked with being
  /// Dismissed will not be returned by other queries.
  Future<bool> requestDismissEvent(int eventUID) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    try{
      Response response = await dio.post("/App/Events/eid=$eventUID/"
          "uid=${user.UID}/Dismiss");
      return response.data["event"]["eid"] == eventUID;
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Dismiss Event"));
      } else {
        return Future.error("Internal app error while Dismissing Event");
      }
    }
  }

  /// Requests for an [Event] to be marked as Recommended in the back-end.
  ///
  /// Given a list of Events through the [events] parameter, the back-end
  /// marks them as being Recommended to this user, setting
  /// [Event.recommended]. Events marked as such will show up in the Personal
  /// Feed.
  Future<List<bool>> requestRecommendation(List<Event> events) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    Future<List<bool>> result;
    result = Future.wait<bool>(events.map((event) async{
      try{
        Response response = await dio.post(
            "/App/Events/eid=${event.UID}/uid=${user.UID}/"
                "recommendstatus=${event.recommended}");
        return response.data["eid"] == event.UID;
      } catch(error,stacktrace){
        debugPrint("Exception: $error stackTrace: $stacktrace");
        if (error is DioError) {
          return Future.error(Utils.handleDioError(error, "Recommendation "
              "Event"));
        } else {
          return Future.error("Internal app error while Recommending Event");
        }
      }
    }));
    return result;
  }

  /// Requests for an [Event] to be created in the system.
  ///
  /// Given a new Event through the [event] parameter, the back-end
  /// creates an Event in the system with this current user as the
  /// [Event._creator].
  /// An Event created this way will show up in the General Feed, and the
  /// Personal Feed if recommended to a user.
  Future<bool> createEvent(Event event) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));

    try{
      Map<String, dynamic> eventJson = event.toJson();
      eventJson["ecreator"] = user.UID;
      Response response = await dio.post(API_URL+ "/App/Events/Create",
        data: convert.jsonEncode(eventJson));
      return response.data["eid"] == event.UID;
    } catch(error,stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Create Event"));
      } else {
        return Future.error("Internal app error while Createing Event");
      }
    }
  }

  //---------------------- DEBUGGING STUFF ----------------------
  String perSearchKeyword = "";
  String genSearchKeyword = "";

  List<Event> dummyEvents = List<Event>.generate(
      10,
          (i) {
            List<int> randList = Utils.getRandomNumberList(10, 0,
                eventTags.length);
        return Event(i, "Event $i", "This is a very long "
          "description fo the event currantly displayed. This is to test "
          "out how good it looks when it cuts off.", "alguien.importante1@upr"
            ".edu",
          "https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg",
          DateTime.now().add(new Duration(minutes: i*2+5)),
          DateTime.now().add(new Duration(minutes: i*20)),
          DateTime.now(),
          new Room(0, "S-200", "Stefani", 2, "Stefani is Cool", 20,
            "Alguien.importante@upr.edu",
              new Coordinate(18.209641, -67.139923,0)
          ),
          new List.generate(3, (i) => Website(
            "https://portal.upr.edu/rum/portal.php?a=rea_login",
            "link $i")
          ),
            new List.generate(
            Random().nextInt(7) + 3,
            (i) => eventTags[randList[i]]
            ),
          false, null
          );
        }
  );

  List<Event> genSearch = new List();
  List<Event> perSearch = new List();

  void clearPerSearch() => perSearchKeyword = "";
  void clearGenSearch() => genSearchKeyword = "";
  void runLocalSearch(){
    if (perSearchKeyword.isNotEmpty) {
      perSearch.clear();
      dummyEvents.forEach((element) {
        if (element.title.contains(perSearchKeyword)){
          perSearch.add(element);
        } else if (element.description.contains(perSearchKeyword)){
          perSearch.add(element);
        }
      });
    }
    if(genSearchKeyword.isNotEmpty) {
      genSearch.clear();
      dummyEvents.forEach((element) {
        if (element.title.contains(genSearchKeyword)){
          genSearch.add(element);
        } else if (element.description.contains(genSearchKeyword)){
          genSearch.add(element);
        }
      });
    }
  }

  void deleteEvent(Event event){
    dummyEvents.remove(event);
  }

  static List<Tag> eventTags = [Tag(1,"ADMI",0), Tag(2,"ADOF",0),
    Tag(3,"AGRO",0), Tag(4,"ALEM",0), Tag(5,"ANTR",0), Tag(6,"ARTE",0),
    Tag(7,"ASTR",0), Tag(8,"BIND",0), Tag(9,"BIOL",0), Tag(10,"BOTA",0),
    Tag(11,"CFIT",0), Tag(12,"CHIN",0), Tag(13,"CIAN",0), Tag(14,"CIBI",0),
    Tag(15,"CIFI",0), Tag(16,"CIIC",0), Tag(17,"CIMA",0)];
}

