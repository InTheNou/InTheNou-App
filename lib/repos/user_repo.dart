import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/events_repo.dart';

class UserRepo {
  static final UserRepo _instance = UserRepo._internal();

  factory UserRepo() {
    return _instance;
  }

  UserRepo._internal();

  User getUser(){
    // Here we would use the auth token saved locally
    return new User.copy(dummyUser);
  }
  User checkAuthToken(String authToken){

  }
  List<Event> getFollowedEvents(int userUID, int skip,
    int rows){
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
  List<Tag> getUserTags(int userUID){

  }
  bool requestAddTags(int userUID, List<String> tagNames){

  }
  bool requestRemoveTags(int userUID, List<String> tagNames){

  }

  // debug stuff
  User dummyUser = new User("Alguien", "Importante",
      "alguien.importante@upr.edu","student", new List.generate(10, (index)
      => new Tag("Tag$index", 10)), UserPrivilege.User);

  EventsRepo _eventRepo = new EventsRepo();
  List<Event> getFollowedEventsFromSecretePlace(){
    return _eventRepo.getPerEvents(null,null,null,null).where((element)
    => element.followed).toList();
  }
  List<Event> getFollowedEventsFromSecretePlace2(){
    return _eventRepo.getPerEvents(null,null,null,null);
  }

}