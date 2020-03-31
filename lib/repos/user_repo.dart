import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/session.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static final UserRepo _instance = UserRepo._internal();

  factory UserRepo() {
    return _instance;
  }

  UserRepo._internal();

  /// Check if there is a Session saved locally.
  /// IF there isn't one then just send null so the user goes to Login
  /// If there is one, check with he backend to see if its valid. In the
  /// case that it is valid then the user can be routed to the app,
  /// otherwise the user is routed to the login to re-auth.
  Future<Session> getSession() async{
    final SharedPreferences prefs = await _prefs;
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
    final SharedPreferences prefs = await _prefs;
    return Future.delayed(Duration(seconds: 3)).then((onValue) {
      prefs.setString(USER_SESSION_KEY, "totally valid session");
      return dummyUser;
    });
  }

  Future<User> createUser(UserRole role, List<Tag> tags) async{
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
  logOut() async{
    final SharedPreferences prefs = await _prefs;
    Future.delayed(Duration(seconds: 3)).then((onValue) {
      prefs.setString(USER_SESSION_KEY, null);
      dummyUser = null; // debug
    });
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
  User dummyUser = new User("Alguien", "Importante",
      "alguien.importante@upr.edu",UserRole.Student,
      [Tag("ADMI",INITIAL_TAG_WEIGHT), Tag("ADOF",INITIAL_TAG_WEIGHT),
        Tag("AGRO",INITIAL_TAG_WEIGHT), Tag("ALEM",INITIAL_TAG_WEIGHT),
        Tag("ANTR",INITIAL_TAG_WEIGHT)],
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
        return element.followed && element.startDateTime.isAfter(DateTime.now());
      }).toList();
    });
  }

}