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


  List<Event> getFollowedEvents(int userUID, int skip,
    int rows){
    // For now It's just getting it from a secrete place, it should just get it
    // straight from the server
    return getFollowedEventsFromSecretePlace();
  }

  Future<List<Event>> getAllFollowedEvents() async{
    // For now It's just getting it from a secrete place, it should just get it
    // straight from the server
    return getFollowedEventsFromSecretePlace();
  }

  List<Event> getCreatedEvents(int userUID, int skip,
      int rows){
    // For now It's just getting it from a secrete place, it should just get it
    // straight from the server
    return getFollowedEventsFromSecretePlace2();
  }
  bool requestDeleteEvents(int userUID, Event event){
    _eventRepo.deleteEvent(event);
    return true;
  }
  Future<List<Tag>> getUserTags() async{
    return [Tag("Tag1", 20), Tag("Tag2", 20), Tag("Tag3", 20), Tag("Tag4", 20),
      Tag("Tag5", 20)];
  }
  bool requestAddTags(int userUID, List<String> tagNames){

  }
  bool requestRemoveTags(int userUID, List<String> tagNames){

  }

  // debug stuff
  User dummyUser = new User("Alguien", "Importante",
      "alguien.importante@upr.edu",UserRole.Student, new List.generate(10, (index)
      => new Tag("Tag$index", 10)), UserPrivilege.EventCreator);

  EventsRepo _eventRepo = new EventsRepo();
  List<Event> getFollowedEventsFromSecretePlace(){
    return _eventRepo.getPerEvents(null,null,null,null).where((element)
    => element.followed).toList();
  }
  List<Event> getFollowedEventsFromSecretePlace2(){
    return _eventRepo.getPerEvents(null,null,null,null);
  }

}