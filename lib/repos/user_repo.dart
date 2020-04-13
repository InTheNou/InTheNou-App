import 'dart:io';
import 'dart:convert' as convert;
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:InTheNou/start_up_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {

  static final UserRepo _instance = UserRepo._internal();
  final ApiConnection apiConnection = ApiConnection();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/userinfo.profile',
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/contacts.readonly',
        "openid",
      ]
  );

  Dio dio;
  GoogleSignInAccount _userAccount;
  int _userID;

  factory UserRepo() {
    return _instance;
  }

  UserRepo._internal(){
    dio = apiConnection.dio;
  }

  /// Verify there is a user logged in and a valid session
  ///
  /// This is the first thing called when the user goes through the
  /// [StartUpView]. It calls [GoogleSignIn] to check the user account. If
  /// there is none then it will throw an [GoogleSignIn.kSignInRequiredError]
  /// signifying that the user should be shown the login screen. It can also
  /// throw other errors like [GoogleSignIn.kNetworkError] that will be shown
  /// tot he user.
  ///
  /// Next we check if there is a Session saved locally in [ApiConnection],
  /// in the case were there is none then a
  /// [GoogleSignIn.kSignInRequiredError] is thrown signifying that the user
  /// should be shown the login screen.
  ///
  /// After this there is currently a dummy method that could be used to
  /// check the validity of the session with the backend. It will always
  /// return true since the Session don't expire right now. In the case that
  /// the Session is not valid then the [GoogleSignIn.kSignInRequiredError]
  /// is thrown again.
  Future<Cookie> getSession() async{
    try{
      _userAccount = await _googleSignIn.signInSilently(suppressErrors: false);

      Cookie session = apiConnection.session;
      if (session == null) {
        return Future.error(PlatformException(
            code: GoogleSignIn.kSignInRequiredError));
      }
      return checkSession(session).then((value) {
        return value ? session : Future.error(PlatformException(
            code: GoogleSignIn.kSignInRequiredError));
      });
    }catch(error, stacktrace){
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error(error);
    }
//    await _googleSignIn.signInSilently().then((GoogleSignInAccount acc) {
//      _userAccount = acc;
//    });
//    if(_userAccount == null){
//      return null;
//    }
//    Cookie session = apiConnection.session;
//    if(session == null){
//      return null;
//    }
//    return checkSession(session).then((value) {
//      return value ? session : null;
//    });
  }

  /// Verify the validity of the Session with the backend
  ///
  /// Calls the API and check if the session is not expired
  /// [session] being the locally saved Flask Session cookie.
  ///
  /// Currently it is a dummy function, here just to leave the possibility of
  /// a verification process.
  Future<bool> checkSession(Cookie session){
    return Future.delayed(Duration(seconds: 1)).then((onValue) {
      return true;
    });
  }

  /// Shows the Google sign in screen and contacts the backend to check the
  /// account
  ///
  /// An account selection is shown with [GoogleSignIn] for the user to
  /// authorize the application. After this we get the user's information
  /// from [GoogleSignInAccount] and the
  /// [GoogleSignInAuthentication.accessToken] so it can be sent to
  /// the backend with the login route. If the user doesn't have an account
  /// in our system then no [User._UID] is returned and the user will be
  /// routed to the Account Creation. Otherwise the UID is provided by the
  /// backend and the user can proceed to the app.
  Future<int> logIn() async {
    _userAccount = await _googleSignIn.signIn();
    var auth = await _userAccount.authentication;
    var values = {
      "access_token": auth.accessToken,
      "id": _userAccount.id,
      "email":_userAccount.email,
      "display_name":_userAccount.displayName,
    };

    try{
      Response response = await dio.post("/App/login",
          data: convert.jsonEncode(values));
      // this is because we receive an error and no uid when the user is new
      if(response.data["uid"] == null){
        return null;
      }
      return int.parse(response.data['uid']);
    } catch(error, stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Sign in") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while Signing in");
      }
    }
  }

  /// Calls the backend to get the user information.
  ///
  /// The method contacts the backend through the route to get user
  /// information by UID using the provided [User_.UID] via [uid].
  /// Once the user information is returned, it it parsed from the json to a
  /// [User] object.
  Future<User> getUserInfo(int uid) async{
    SharedPreferences prefs = await _prefs;
    try{
      Response response = await dio.get("/App/Users/uid=$uid");
      User user;

      if(response.data != null){
        user = User.fromJson(response.data);
      }
      prefs.setString(USER_KEY, convert.jsonEncode(user.toJson()));
      return user;
    } catch(error, stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "User Data") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while getting User Data in");
      }
    }
  }

  /// Creates the user account in our system
  ///
  /// The method is called after the user has chosen the [Tag]s of their
  /// interest. It calls the sign up route with the Google account
  /// information as well as the selected Tags provided by [tags]. After a
  /// successful sign up the backend returns the new user's [User._UID] and the
  /// complete user information is gathered from the backend using
  /// [getUserInfo] ans is returned as [User] as well as saved locally for
  /// backup.
  Future<User> signUp(List<Tag> tags) async{
    try{
      // Prepare the data to create the user account
      var auth = await _userAccount.authentication;
      var tagsJson = Tag.toJsonList(tags);
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

      return newUser;
    } catch(error, stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Create User") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while Creating User");
      }
    }
  }

  /// Gathers the user information from local storage backup
  Future<User> getUserFromPrefrs() async{
    SharedPreferences prefs = await _prefs;
    if(prefs.get(USER_KEY) == null)
      return null;
    return User.fromJson(convert.jsonDecode(prefs.get(USER_KEY)));
  }

  /// Utility method that provides the [User._UID]
  ///
  /// If the [User._UID] hasn't been fetched before then it gets it from the
  /// local storage backup and makes it available for the next time it is
  /// fetched.
  Future<int> getUserID() async{
    if(_userID == null){
      SharedPreferences prefs = await _prefs;
      if(prefs.get(USER_KEY) == null)
        return null;
      _userID = convert.jsonDecode(prefs.get(USER_KEY))["uid"];
    }
    return _userID;
  }


  /// Removes the user account from the app and deletes the session
  ///
  /// Removes the Session from the local storage as well as the backend. It
  /// also signs out of the google account so that the user may sign
  /// back in.
  logOut() async{
    try{
      // Do the logout request
//      Response response = await dio.get("/App/logout");

//      print(response);
      final SharedPreferences prefs = await _prefs;
      prefs.setString(USER_SESSION_KEY, null);
      apiConnection.deleteSession();
      _googleSignIn.signOut();
      _userID = null;
      _userAccount = null;

    } catch(error, stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Create User") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while Creating User");
      }
    }
  }

  /// Calls the backend to get the Followed [Event]s by the current [User]
  ///
  /// The method calls the backend to get the Followed events of the current
  /// user on the app. The parameters [skipEvents] and [numEvents] are
  /// provided for pagination.
  Future<List<Event>> getFollowedEvents(int skipEvents, int numEvents) async{
    try{
      int uid = await getUserID();
      Response response = await dio.get(
          "/App/Events/Following//uid=$uid/offset=$skipEvents/limit"
              "=$numEvents");
      var eventResults = new List<Event>();

      if(response.data["events"] != null){
        response.data["events"].forEach((element) {
          eventResults.add(Event.resultFromJson(element,
              isFollowed: true));
        });
      }
      return eventResults;
    } catch(error, stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Followed Events") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while getting Followed Events");
      }
    }
  }

  Future<List<Event>> getFEventsHistory(int skipEvents, int numEvents) async{
    try{
      int uid = await getUserID();
      Response response = await dio.get(
          "/App/Events/History//uid=$uid/offset=$skipEvents/limit"
              "=$numEvents");
      var eventResults = new List<Event>();

      if(response.data["events"] != null){
        response.data["events"].forEach((element) {
          eventResults.add(Event.resultFromJson(element,
              isFollowed: true));
        });
      }
      return eventResults;
    } catch(error, stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Events History") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while getting Events History");
      }
    }
  }

  /// Calls the backend to get the Created [Event]s by the current [User]
  ///
  /// The method calls the backend to get the Created events by the current
  /// user on the app. The parameters [skipEvents] and [numEvents] are
  /// provided for pagination.
  Future<List<Event>> getCreatedEvents(int skipEvents, int numEvents) async{
    try{
      int uid = await getUserID();
      Response response = await dio.get(
          "/App/Events/Created//uid=$uid/offset=$skipEvents/limit=$numEvents");
      var eventResults = new List<Event>();
      if(response.data["events"] != null){
        response.data["events"].forEach((element) {
          eventResults.add(Event.resultFromJson(element,
              isFollowed: true));
        });
      }
      return eventResults;
    } catch(error, stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Credted Events") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while getting Created Events");
      }
    }
  }

  /// Calls the backend to get the [Tags] associated to the current [User]
  ///
  Future<List<Tag>> getUserTags() async{
    try{
      Response response = await dio.get("/App/Tags/UserTags");
      var tagResults = new List<Tag>();

      if(response.data["tags"] != null){
        response.data["tags"].forEach((element) {
          tagResults.add(Tag.fromJson(element));
        });
      }
      return tagResults;
    } catch(error, stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Credted Events") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error while getting Created Events");
      }
    }
  }

}