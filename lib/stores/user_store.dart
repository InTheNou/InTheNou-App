import 'dart:io';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:InTheNou/repos/tag_repo.dart';
import 'package:InTheNou/repos/user_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class UserStore extends flux.Store{

  static final flux.StoreToken userStoreToken = new flux.StoreToken(new
    UserStore());
  static final UserRepo _userRepo = new UserRepo();
  static final EventsRepo _eventRepo = new EventsRepo();
  static final TagRepo _tagRepo = new TagRepo();

  User _user;
  Future<List<Event>> _followedEvents;
  Future<List<Event>> _historyEvents;
  Future<List<Event>> _createdEvents;
  Future<bool> _cancelEventResult= Future.value(null);
  Future<List<Tag>> _userTags;

  UserRole _selectedRole;
  List<Tag> _selectedTags = new List();
  Map<Tag, bool> _allTags = new Map();
  Map<Tag, bool> _searchTags = new Map();

  List<UserRole> _userRoles = [
    UserRole.Student,
    UserRole.TeachingPersonnel,
    UserRole.NonTeachingPersonnel];

  bool _isFollowedLoading = false;
  bool _isCreatedLoading = false;
  String _followedEventError;
  String _createdEventError;

  Future<User> loginUser;
  Future<Cookie> session;

  UserStore() {

     _tagRepo.getAllTagsAsMap().then((tags) {
       _allTags = tags;
       _searchTags = tags;
     });

    triggerOnAction(refreshFollowedAction, (_){
      _followedEvents = _userRepo.getFollowedEvents(0, EVENTS_TO_FETCH);
    });
    triggerOnAction(refreshHistoryAction, (_){
      _historyEvents = _userRepo.getFEventsHistory(0, EVENTS_TO_FETCH);
    });
    triggerOnAction(refreshCreatedAction, (_){
      _createdEvents = _userRepo.getCreatedEvents(0, EVENTS_TO_FETCH);
    });
    triggerOnAction(cancelEventAction, (Event event) {
      _cancelEventResult = _eventRepo.cancelEvent(event);
    });
    triggerOnAction(getMyTagsAction, (_) {
      _userTags = _userRepo.getUserTags();
    });
    triggerOnConditionalAction(callAuthAction, (_) async{
      return _userRepo.logIn().then((uid) async{
        if(uid != null){
          return _userRepo.getUserInfo(uid).then((user){
            loginUser = Future.value(user);
            print(user);
            _user = user;
            return true;
          }).catchError((e){
            loginUser = Future.error(e);
            return true;
          });
        }
        loginUser = Future.value(null);
        return true;
      }).catchError((e){
        loginUser = Future.error(e);
        return true;
      });
    });
     triggerOnAction(fetchSession, (_) {
      session = getSession();
    });
    triggerOnAction(resetStartUpError, (_) {
      session = null;
    });
    triggerOnAction(resetLoginError, (_) {
      loginUser = null;
    });
    triggerOnAction(selectRoleAction, (UserRole role) {
      _selectedRole = role;
    });
    triggerOnAction(searchedTagAction, (String keyword) {
      _searchTags.clear();
      _allTags.forEach((key, value) {
        if(key.name.toUpperCase().contains(keyword.toUpperCase())){
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
      loginUser = Future.value(null);
      trigger();
      return _userRepo.signUp(_selectedTags).then((value) {
                _user = value;
                _selectedRole = null;
                _selectedTags = List();
                _searchTags = _allTags;
                loginUser = Future.value(value);
                return true;
      });
    });

    triggerOnConditionalAction(changeUserPrivilegeAction, (_){
      _user.userPrivilege = _user.userPrivilege == UserPrivilege.User?
        UserPrivilege.EventCreator :
        UserPrivilege.User;
      return true;
    });

  }

  ///
  /// This method calls the backend to get the information on the uer after
  /// it has logged in with Google.
  /// The [Future] can return a Null if the user is new to the system.
  /// Otherwise it return the full User information
  Future<User> getUser() async{
    return _userRepo.getUserFromPrefrs().then((value) {
      _user = value;
      trigger();
      return _user;
    });
  }

  ///
  /// Method gets the Session saved locally, if there is one.
  /// If there is none or the Session found is invalid, then Null is returned
  Future<Cookie> getSession(){
    return _userRepo.getSession();
  }

  User get user => _user;
  Future<List<Event>> get followedEvents => _followedEvents;
  Future<List<Event>> get historyEvents => _historyEvents;
  Future<List<Event>> get createdEvents => _createdEvents;
  Future<bool> get cancelEventResult => _cancelEventResult;
  Future<List<Tag>> get userTags => _userTags;

  UserRole get selectedRole => _selectedRole;
  List<UserRole> get userRoles => _userRoles;
  Map<Tag, bool> get searchTags => _searchTags;
  List<Tag> get selectedTags => _selectedTags;

  String get followedEventError => _followedEventError;
  String get createdEventError => _createdEventError;
  bool get isFollowedLoading => _isFollowedLoading;
  bool get isCreatedLoading => _isCreatedLoading;

}
//Profile Actions
final flux.Action refreshFollowedAction = new flux.Action();
final flux.Action refreshHistoryAction = new flux.Action();
final flux.Action refreshCreatedAction = new flux.Action();
final flux.Action<Event> cancelEventAction = new flux.Action();
final flux.Action getMyTagsAction = new flux.Action();

//AccountCreation and Auth Actions
final flux.Action fetchSession = new flux.Action();
final flux.Action callAuthAction = new flux.Action();
final flux.Action resetStartUpError = new flux.Action();
final flux.Action resetLoginError = new flux.Action();
final flux.Action<UserRole> selectRoleAction = new flux.Action();
final flux.Action<String> searchedTagAction = new flux.Action();
final flux.Action<MapEntry<Tag,bool>> toggleTagAction = new flux.Action();
final flux.Action createUserAction = new flux.Action();

final flux.Action changeUserPrivilegeAction = new flux.Action();
