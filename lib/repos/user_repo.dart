import 'dart:io';
import 'dart:convert' as convert;
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserRepo {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var client = http.Client();

  static final UserRepo _instance = UserRepo._internal();
  final ApiConnection apiConnection = ApiConnection();
  Dio dio;

  GoogleSignInAccount _userAccount;
  int _userID;

  factory UserRepo() {
    return _instance;
  }

  UserRepo._internal(){
    dio = apiConnection.dio;
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/contacts.readonly',
      "openid",
    ]
  );

  Future<int> callAuthService() async {
//    _userAccount = await _googleSignIn.signIn();
//    var auth = await _userAccount.authentication;
//    Map values = {
//      "access_token": auth.accessToken,
//      "id": _userAccount.id,
//      "email":_userAccount.email,
//      "display_name":_userAccount.displayName,
//    };
//
//    try{
//      Response response = await dio.post("/App/login",
//          data: convert.jsonEncode(values));
//      print(response.data['uid']);
//      print(response.data['newAccount']);
//      return int.parse(response.data['uid']);
//    } catch(error, stacktrace){
//      if (error is DioError) {
//        return Future.error(Utils.handleDioError(error, "Sign in") );
//      } else {
//        debugPrint("Exception: $error stackTrace: $stacktrace");
//        return Future.error("Internal app error while Signing in");
//      }
//    }
    return 4;
  }


  /// Check if there is a Session saved locally.
  /// IF there isn't one then just send null so the user goes to Login
  /// If there is one, check with he backend to see if its valid. In the
  /// case that it is valid then the user can be routed to the app,
  /// otherwise the user is routed to the login to re-auth.
  Future<Cookie> getSession() async{
    await _googleSignIn.signInSilently().then((GoogleSignInAccount acc) {
      _userAccount = acc;
    });
    if(_userAccount == null){
      return null;
    }
    Cookie session = apiConnection.session;
    if(session == null){
      return null;
    }
    return checkSession(session).then((value) {
      return value ? session : null;
    });
  }

  /// Calls the API and check if the session is not expired
  /// [session] being the locally saved Flask Session cookie
  Future<bool> checkSession(Cookie session){
    return Future.delayed(Duration(seconds: 1)).then((onValue) {
      return true;
    });
  }

  /// Calls the backend to get the user information after the login.
  Future<User> getUserInfo(int uid) async{
    SharedPreferences prefs = await _prefs;
    try{
      Response response = await dio.get("/App/Users/uid=$uid");
      User user;
      Map<String, dynamic> jsonResponse = (response.data);
      if(jsonResponse != null){
        user = User.fromJson(jsonResponse);
      }
      prefs.setString(USER_KEY, convert.jsonEncode(user.toJson()));
      return user;
    } catch(error, stacktrace){
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "User Data") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while getting User Data in");
      }
    }
  }

  Future<User> createUser(List<Tag> tags) async{
    try{
//      List<Map<String, dynamic>> tagsJson = Tag.toJsonList(tags);
//
//      Response response = await dio.post("/App/Tags/User/Add",
//        data: convert.jsonEncode(tagsJson));
//      print(response);
      User newUser = await getUserFromPrefrs();
      newUser.tags = tags;
      SharedPreferences prefs = await _prefs;

      prefs.setString(USER_KEY, convert.jsonEncode(newUser.toJson()));

      return newUser;
    } catch(error, stacktrace){
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Create User") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while Creating User");
      }
    }
    return await getUserFromPrefrs();
  }

  Future<User> getUserFromPrefrs() async{
    SharedPreferences prefs = await _prefs;
    if(prefs.get(USER_KEY) == null)
      return null;
    return User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));
  }

  Future<int> getUserID() async{
    if(_userID != null){
      return _userID;
    }
    SharedPreferences prefs = await _prefs;
    if(prefs.get(USER_KEY) == null)
      return null;
    return convert.jsonDecode(prefs.get(USER_KEY))["uid"];
  }


  /// Removes the Session from the local storage so that the user may sign
  /// back in.
  Future<bool> logOut() async{
    final SharedPreferences prefs = await _prefs;
    return Future.delayed(Duration(seconds: 1)).then((onValue) {
      prefs.setString(USER_SESSION_KEY, null);
      dummyUser = null; // debug
      return true;
    });
//    _googleSignIn.signOut();
  }

  Future<List<Event>> getFollowedEvents(int skipEvents, int numEvents) async{
    try{
      Response response = await dio.get(
          "/App/Events/Following//uid=${getUserID()}/offset=$skipEvents/limit=$numEvents");
      List<Event> eventResults = new List();
      List jsonResponse = response.data["events"];
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          eventResults.add(Event.resultFromJson(element,
              isFollowed: true));
        });
      }
      return eventResults;
    } catch(error, stacktrace){
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Followed Events") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while getting Followed Events");
      }
    }
  }

  Future<List<Event>> getCreatedEvents(int skipEvents, int numEvents) async{
    try{
      Response response = await dio.get(
          "/App/Events/Created//uid=${getUserID()}/offset=$skipEvents/limit=$numEvents");
      List<Event> eventResults = new List();
      List jsonResponse = response.data["events"];
      if(jsonResponse != null){
        jsonResponse.forEach((element) {
          eventResults.add(Event.resultFromJson(element,
              isFollowed: true));
        });
      }
      return eventResults;
    } catch(error, stacktrace){
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Credted Events") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while getting Created Events");
      }
    }
  }

  bool requestDeleteEvents(Event event){
    _eventRepo.deleteEvent(event);
    return true;
  }
  Future<List<Tag>> getUserTags() async{
    return dummyUser.tags;
  }

  // debug stuff
  static User dummyUser = new User(4,"Alguien", "Importante",
      "alguien.importante@upr.edu",UserRole.Student,
      [Tag(1,"ADMI",INITIAL_TAG_WEIGHT), Tag(2,"ADOF",INITIAL_TAG_WEIGHT),
        Tag(3,"AGRO",INITIAL_TAG_WEIGHT), Tag(4,"ALEM",INITIAL_TAG_WEIGHT),
        Tag(5,"ANTR",INITIAL_TAG_WEIGHT)],
      UserPrivilege.EventCreator);

  EventsRepo _eventRepo = new EventsRepo();



}