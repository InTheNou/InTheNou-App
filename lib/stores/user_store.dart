import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/session.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/tag_repo.dart';
import 'package:InTheNou/repos/user_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class UserStore extends flux.Store{

  static final flux.StoreToken userStoreToken = new flux.StoreToken(new
    UserStore());

  User _user;
  List<Event> _followedEvents = new List();
  List<Event> _createdEvents = new List();
  
  UserRole _selectedRole;
  List<Tag> _selectedTags = new List();
  Map<Tag, bool> _allTags = new Map();
  Map<Tag, bool> _searchTags = new Map();

  List<UserRole> _userRoles = [
    UserRole.Student,
    UserRole.TeachingPersonnel,
    UserRole.NonTeachingPersonnel];

  UserRepo _userRepo = new UserRepo();
  TagRepo _tagRepo = new TagRepo();

  static final UserStore _instance = UserStore._internal();

  factory UserStore() {
    return _instance;
  }

  UserStore._internal() {
    _user = _userRepo.getUser();
    _allTags = _tagRepo.getAllTagsAsMap();
    _searchTags = _tagRepo.getAllTagsAsMap();

    triggerOnAction(refreshFollowedAction, (_){
      _followedEvents = _userRepo.getFollowedEvents(0, 0, EVENTS_TO_FETCH);
    });
    triggerOnAction(refreshCreatedAction, (_){
      _createdEvents = _userRepo.getCreatedEvents(0, 0, EVENTS_TO_FETCH);
    });
    triggerOnAction(cancelEventAction, (Event event){
      _userRepo.requestDeleteEvents(event);
    });
    triggerOnAction(callAuthAction, (_){
      //TODO: Add call to auth service in integration

    });
    triggerOnAction(selectRoleAction, (UserRole role) {
      _selectedRole = role;
    });
    triggerOnAction(searchedTagAction, (String keyword) {
      _searchTags.clear();
      _allTags.forEach((key, value) {
        if(key.name.contains(keyword)){
          _searchTags.putIfAbsent(key, () => value);
        }
      });
    });
    triggerOnAction(toggleTagAction, (MapEntry<Tag,bool> tag) {
      if(_searchTags.containsKey(tag.key)){
        _searchTags.update(tag.key, (value) => tag.value);
        _allTags.update(tag.key, (value) => tag.value);
      }
      if (tag.value){
        _selectedTags.add(tag.key);
      } else {
        _selectedTags.remove(tag.key);
      }
    });
    triggerOnConditionalAction(createUserAction, (_){
      // This is just to give time to show the loading screen
      return _userRepo.createUser(_selectedRole, _selectedTags).then(
              (value) {
                _user = value;
                return true;
      });
    });
  }

  ///
  /// This method calls the backend to get the information on the uer after
  /// it has logged in with Google.
  /// The [Future] can return a Null if the user is new to the system.
  /// Otherwise it return the full User information
  Future<User> getUser () async{
    return _userRepo.getUserInfo().then((value) {
      _user = value;
      return _user;
    });
  }

  ///
  /// Method gets the Session saved locally, if there is one.
  /// If there is none or the Session found is invalid, then Null is returned
  Future<Session> getSession() async{
    return _userRepo.getSession().then((value) {
      return value;
    });
  }

  User get user => _user;
  List<Event> get followedEvents => _followedEvents;
  List<Event> get createdEvents => _createdEvents;
  UserRole get selectedRole => _selectedRole;
  List<UserRole> get userRoles => _userRoles;
  Map<Tag, bool> get searchTags => _searchTags;
  List<Tag> get selectedTags => _selectedTags;

}
//Profile Actions
final flux.Action refreshFollowedAction = new flux.Action();
final flux.Action refreshCreatedAction = new flux.Action();
final flux.Action<Event> cancelEventAction = new flux.Action();
//AccountCreation and Auth Actions
final flux.Action callAuthAction = new flux.Action();
final flux.Action<UserRole> selectRoleAction = new flux.Action();
final flux.Action<String> searchedTagAction = new flux.Action();
final flux.Action<MapEntry<Tag,bool>> toggleTagAction = new flux.Action();
final flux.Action createUserAction = new flux.Action();
