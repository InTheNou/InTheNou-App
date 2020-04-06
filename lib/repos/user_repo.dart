import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/session.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UserRepo {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var client = http.Client();

  static final UserRepo _instance = UserRepo._internal();

  GoogleSignInAccount _userAccount;

  factory UserRepo() {
    return _instance;
  }

  UserRepo._internal();

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/contacts.readonly',
      "openid"
    ]
  );

  Future<bool> callAuthService() async {
//    _userAccount = await _googleSignIn.signIn();
//    print(_userAccount.toString());
//    var response = await client.get(API_URL+"/App/login");
//    debugPrint('Response body: ${response.body}');
//    RegExp reg = RegExp(r"(https:)(.*)(?=, 'OCAK')",multiLine: true);
//    String url = reg.stringMatch(response.body).split(RegExp(r"', "))[0];
    return true;
  }

  /// Check if there is a Session saved locally.
  /// IF there isn't one then just send null so the user goes to Login
  /// If there is one, check with he backend to see if its valid. In the
  /// case that it is valid then the user can be routed to the app,
  /// otherwise the user is routed to the login to re-auth.
  Future<Session> getSession() async{
    final SharedPreferences prefs = await _prefs;
    _googleSignIn.signInSilently().then((GoogleSignInAccount acc) {
      if(acc == null){

      } else{
        _userAccount = acc;
      }
    });
    return Future.delayed(Duration(seconds: 3)).then((onValue) {
      Session session = Session(prefs.getString(USER_SESSION_KEY));
      if(session.value == null){
        return null;
      }
      return checkSession(session).then((value) {
        return value ? session : null;
      });
    });
  }

  /// Calls the API and check if the session is not expired
  /// [session] being the locally saved Flask Session cookie
  Future<bool> checkSession(Session session){
    return Future.delayed(Duration(seconds: 1)).then((onValue) {
      return true;
    });
  }


  /// Calls the backend to get the user information after the login redirect.
  /// Also, the session returned by the backend is saved locally.
  Future<User> getUserInfo() async{
    return dummyUser;
  }

  Future<User> createUser(UserRole role, List<Tag> tags) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(USER_SESSION_KEY, "totally valid session");

    return Future.delayed(Duration(seconds: 3)).then((onValue) {
      dummyUser = new User("Alguien", "Importante",
          "alguien.importante@upr.edu",role, tags, UserPrivilege.EventCreator);
      return dummyUser;
    });
  }

  User getUser(){
    return dummyUser;
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


  Future<List<Event>> getFollowedEvents(int skip, int rows) async{
    // For now It's just getting it from a secrete place, it should just get it
    // straight from the server
    return getFollowedEventsFromSecretPlace();
  }

  Future<List<Event>> getAllFollowedEvents() async{
    // For now It's just getting it from a secrete place, it should just get it
    // straight from the server
    return getFollowedEventsFromSecretPlace();
  }

  Future<List<Event>> getCreatedEvents(int userUID, int skip,
      int rows) async{
    // For now It's just getting it from a secrete place, it should just get it
    // straight from the server
    return getFollowedEventsFromSecretPlace2();
  }
  bool requestDeleteEvents(Event event){
    _eventRepo.deleteEvent(event);
    return true;
  }
  Future<List<Tag>> getUserTags() async{
    return dummyUser.tags;
  }

  // debug stuff
  static User dummyUser = new User("Alguien", "Importante",
      "alguien.importante@upr.edu",UserRole.Student,
      [Tag(1,"ADMI",INITIAL_TAG_WEIGHT), Tag(2,"ADOF",INITIAL_TAG_WEIGHT),
        Tag(3,"AGRO",INITIAL_TAG_WEIGHT), Tag(4,"ALEM",INITIAL_TAG_WEIGHT),
        Tag(5,"ANTR",INITIAL_TAG_WEIGHT)],
      UserPrivilege.EventCreator);

  EventsRepo _eventRepo = new EventsRepo();
  Future<List<Event>> getFollowedEventsFromSecretPlace() async{
    return _eventRepo.getGenEvents(0,10000000).then((List<Event> value) {
      return value.where((element){
        return element.followed;
      }).toList();
    });

  }
  Future<List<Event>> getFollowedEventsFromSecretPlace2() async{
    return _eventRepo.getGenEvents(0,10000000).then((List<Event> value) {
      return value.where((element){
        return element.creator == "alguien.importante@upr.edu"
            && element.startDateTime.isAfter(DateTime.now());
      }).toList();
    });
  }

}