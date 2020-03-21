import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/user_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class UserStore extends flux.Store{

  User _user;
  List<Event> _followedEvents = new List();
  List<Event> _createdEvents = new List();

  UserRepo _userRepo = new UserRepo();

  UserStore() {
    _user = _userRepo.getUser();

    triggerOnAction(refreshFollowedEventsAction, (_){
      _followedEvents = _userRepo.getFollowedEvents(0, 0, EVENTS_TO_FETCH);
    });
    triggerOnAction(refreshCreatedEventsAction, (_){
      _createdEvents = _userRepo.getCreatedEvents(0, 0, EVENTS_TO_FETCH);
    });
    triggerOnAction(cancelEventAction, (Event event){
      _userRepo.requestDeleteEvents(0, event);
    });
  }

  User get user => _user;
  List<Event> get followedEvents => _followedEvents;
  List<Event> get createdEvents => _createdEvents;

}
final flux.Action refreshFollowedEventsAction = new flux.Action();
final flux.Action refreshCreatedEventsAction = new flux.Action();
final flux.Action<Event> cancelEventAction = new flux.Action();

final flux.StoreToken userStoreToken = new flux.StoreToken(new UserStore());