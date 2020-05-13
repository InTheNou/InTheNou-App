import 'dart:convert' as convert;
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@category Repo}
class EventsRepo {

  static final EventsRepo _instance = EventsRepo._internal();
  final ApiConnection apiConnection = ApiConnection();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  factory EventsRepo() {
    return _instance;
  }

  EventsRepo._internal();

  /// Calls the back-end to get the Events for the General Feed
  ///
  /// The method returns all active and non-dismissed Events in the system. The
  /// parameter [skipEvents] can be supplied to let the back-end know the
  /// first event that needs to be returned, this along with [numEvents]
  /// permits performing pagination and only showing a few Events at a time.
  /// To get all the Events at once just supply a very big number to
  /// [numEvents].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Event>> getGenEvents (int skipEvents, int numEvents) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.get(
          "/App/Events/General/offset=$skipEvents"
              "/limit=$numEvents");
      List<Event> eventResults = new List();

      if(response.data["events"] != null){
        response.data["events"].forEach((element) {
          eventResults.add(Event.resultFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting General "
            "Events") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting General Events");
      }
    }
  }

  /// Calls the back-end to get the Events for the Personal Feed.
  ///
  /// The method returns all active Recommended and non-dismissed [Event]s in
  /// the system. The parameter [skipEvents] can be supplied to let the
  /// back-end know the first event that needs to be returned, this along
  /// with [numEvents] permits performing pagination and only showing a few
  /// Events at a time. To get all the Events at once just supply a very big
  /// number to [numEvents].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Event>> getPerEvents(int skipEvents, int numEvents) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.get(
          "/App/Events/Recommended/offset=$skipEvents/"
              "limit=$numEvents");
      List<Event> eventResults = new List();

      if(response.data["events"] != null){
        response.data["events"].forEach((element) {
          eventResults.add(Event.resultFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Getting Personal "
            "Events"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Personal Events");
      }
    }
  }

  /// Calls the back-end to get [Event]s created after [lastDate].
  ///
  /// The parameter [lastDate] is a DateTime object in String form, with the
  /// format yyyy-MM-dd hh:mm:ss.
  /// This method is used in the Recommendation Feature.
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Event>> getNewEvents(String lastDate) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.get(
          "/App/Events/CAT/timestamp=$lastDate");
      List<Event> eventResults = new List();

      if(response.data["events"] != null){
        response.data["events"].forEach((element) {
          eventResults.add(Event.recommendationFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting New Events "
            "Events"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting New Events");
      }
    }
  }

  /// Calls the back-end to get [Event]s deleted after [lastDate].
  ///
  /// The parameter [lastDate] is a DateTime object in String form, with the
  /// format yyyy-MM-dd hh:mm:ss.
  /// This method is used in the Cancellation Notification.
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Event>> getDeletedEvents(String lastDate) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.get(
          "/App/Events/Deleted/New/timestamp=$lastDate");
      List<Event> eventResults = new List();

      if(response.data["events"] != null){
        response.data["events"].forEach((element) {
          eventResults.add(Event.recommendationFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting Cancelled "
            "Events"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Cancelled Events");
      }
    }
  }

  /// Calls the back-end with a search query for the General Feed
  ///
  /// The method returns all active and non-dismissed Events in the system
  /// that match the [keyword] in their [Event._title] or
  /// [Event._description]. The parameter [skipEvents] can be supplied to let the
  /// back-end know the first event that needs to be returned, this along
  /// with [numEvents] permits performing pagination and only showing a few
  /// Events at a time.
  /// To get all the Events at once just supply a very big number to
  /// [numEvents].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Event>> searchGenEvents(String keyword, int skipEvents,
      int numEvents) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.get(
          "/App/Events/General/search=$keyword/offset=$skipEvents/limit=$numEvents");
      List<Event> eventResults = new List();

      List jsonResponse = response.data["events"];
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          eventResults.add(Event.resultFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Searching General "
            "Events"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
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
  /// To get all the Events at once just supply a very big number to
  /// [numEvents].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<Event>> searchPerEvents(String keyword, int skipEvents,
      int numEvents) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.get(
          "/App/Events/Recommended/search=$keyword/offset=$skipEvents/limit"
              "=$numEvents");
      List<Event> eventResults = new List();

      List jsonResponse = response.data["events"];
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          eventResults.add(Event.resultFromJson(element));
        });
      }
      return eventResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error,
            "Searching Personal Events"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Searching Personal Events");
      }
    }
  }

  /// Calls the back-end to get all the information on a specific [Event].
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// will return detailed information about the [Event] that matches the UID.
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<Event> getEvent(int eventUID) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.get("/App/Events/eid=$eventUID/Interaction");

      return Event.fromJson(response.data);
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting Event"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while Getting Event");
      }
    }
  }

  /// Requests for an [Event] to be marked as Followed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being Followed by this user by setting [Event.followed].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<bool> requestFollowEvent(int eventUID) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.post("/App/Events/eid=$eventUID/"
          "/Follow");

      return response.data["event"]["eid"] == eventUID;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Follow Event"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while Follwing Event");
      }
    }
  }

  /// Requests for an [Event] to be marked as UnFollowed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being UnFollowed by this user by setting [Event.followed].
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<bool> requestUnFollowEvent(int eventUID) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.post("/App/Events/eid=$eventUID/"
          "Unfollow");

      return response.data["event"]["eid"] == eventUID;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "UnFollow Event"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while UnFollwing Event");
      }
    }
  }

  /// Requests for an [Event] to be marked as Dismissed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being Dismissed by this user. Events marked with being
  /// Dismissed will not be returned by other queries.
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<bool> requestDismissEvent(int eventUID) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.post("/App/Events/eid=$eventUID/"
          "Dismiss");

      return response.data["event"]["eid"] == eventUID;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Dismiss Event"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
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
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<List<bool>> requestRecommendation(List<Event> events) async{
    Future<List<bool>> result;
    result = Future.wait<bool>(events.map((event) async{
      try{
        await apiConnection.ensureInitialized();

        Response response = await apiConnection.dio.post(
            "/App/Events/eid=${event.UID}/"
                "recommendstatus=${event.recommended}");

        return response.data["eid"] == event.UID;
      } catch(error,stacktrace){
        if (error is DioError) {
          debugPrint("Exception: $error");
          return Future.error(Utils.handleDioError(error, "Recommendation "
              "Event"));
        } else {
          debugPrint("Exception: $error stackTrace: $stacktrace");
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
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<bool> createEvent(Event event) async{
    SharedPreferences prefs = await _prefs;
    User user = User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));
    try{
      await apiConnection.ensureInitialized();

      Map<String, dynamic> eventJson = event.toJson();
      eventJson["ecreator"] = user.UID;
      Response response = await apiConnection.dio.post("/App/Events/Create",
        data: convert.jsonEncode(eventJson));

      if(response.data["eid"] == null){
        return Future.error("We were unable to create the Event, please try "
            "again.");
      }
      return true;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Create Event"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while Creating Event");
      }
    }
  }

  /// Requests for an [Event] to be cancelled in the system.
  ///
  /// Given an Event through the [event] parameter, the back-end
  /// marks the Event in the system as deleted.
  ///
  /// A cancelled event will disappear from the Feeds and if a user is
  /// following it, they will receive a notification that it has been cancelled
  ///
  /// Database Errors are caught by Dio and throw a [DioError] which is
  /// traduced to a proper error with [Utils.handleDioError].
  Future<bool> cancelEvent(Event event) async{
    try{
      await apiConnection.ensureInitialized();

      Response response = await apiConnection.dio.post("/App/Events/eid=${event.UID}"
          "/estatus=deleted");

      return response.data["eid"] == event.UID;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Cancel Event"));
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while Cancelling Event");
      }
    }
  }

}

