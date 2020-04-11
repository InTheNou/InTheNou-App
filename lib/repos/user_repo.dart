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

  Future<int> logIn() async {
    _userAccount = await _googleSignIn.signIn();
    var auth = await _userAccount.authentication;
    Map values = {
      "access_token": auth.accessToken,
      "id": _userAccount.id,
      "email":_userAccount.email,
      "display_name":_userAccount.displayName,
    };

    try{
      Response response = await dio.post("/App/login",
          data: convert.jsonEncode(values));
      // this is becuase we recieve an error and no uid when the user is new
      if(response.data["uid"] == null){
        return null;
      }
      print(response.headers.toString());
      return int.parse(response.data['uid']);
    } catch(error, stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Sign in") );
      } else {
        return Future.error("Internal app error while Signing in");
      }
    }
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
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "User Data") );
      } else {
        return Future.error("Internal app error while getting User Data in");
      }
    }
  }

  Future<User> signUp(List<Tag> tags) async{
    try{
      // Prepare the data to create the user account
      var auth = await _userAccount.authentication;
      List<Map<String, dynamic>> tagsJson = Tag.toJsonList(tags);
      Map values = {
        "access_token": auth.accessToken,
        "id": _userAccount.id,
        "email":_userAccount.email,
        "display_name":_userAccount.displayName,
        "tags": tagsJson
      };
      // Do the signup request
      Response response = await dio.post("/App/signup",
        data: convert.jsonEncode(values));

      // Get the complete information of the user given the response UID
      User newUser = await getUserInfo(response.data["uid"]);

      // Save that user to the local storage
      SharedPreferences prefs = await _prefs;
      prefs.setString(USER_KEY, convert.jsonEncode(newUser.toJson()));
      print(prefs.get(USER_KEY));

      return newUser;
    } catch(error, stacktrace){
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Create User") );
      } else {
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
  logOut() async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(USER_SESSION_KEY, null);
    apiConnection.deleteSession();
    _googleSignIn.signOut();
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
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Followed Events") );
      } else {
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
      debugPrint("Exception: $error stackTrace: $stacktrace");
      if (error is DioError) {
        return Future.error(Utils.handleDioError(error, "Credted Events") );
      } else {
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
      null,
      UserPrivilege.EventCreator);

  EventsRepo _eventRepo = new EventsRepo();



}