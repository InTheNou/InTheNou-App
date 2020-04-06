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
  static final UserRepo _userRepo = new UserRepo();
  static final TagRepo _tagRepo = new TagRepo();

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

  bool _isFollowedLoading = false;
  bool _isCreatedLoading = false;
  String _followedEventError;
  String _createdEventError;

  String _redirectURL = "";

  UserStore() {
    _user = _userRepo.getUser();
    _allTags = _tagRepo.getAllTagsAsMap();
    _searchTags = _tagRepo.getAllTagsAsMap();

    triggerOnConditionalAction(refreshFollowedAction, (_){
      _isFollowedLoading = true;
      trigger();
      return _userRepo.getFollowedEvents(0, EVENTS_TO_FETCH).then(
              (List<Event> value) {
        _followedEvents = value;
        _isFollowedLoading = false;
        return true;
      }).catchError((error){
        _followedEventError = error.toString();
        _isFollowedLoading = false;
        return true;
      });
    });
    triggerOnConditionalAction(refreshCreatedAction, (_){
      _isCreatedLoading = true;
      trigger();
      return _userRepo.getCreatedEvents(0, 0, EVENTS_TO_FETCH).then((value) {
        _createdEvents = value;
        _isCreatedLoading = false;
        return true;
      }).catchError((error){
        _createdEventError = error.toString();
        _isCreatedLoading = false;
        return true;
      });
    });
    triggerOnAction(cancelEventAction, (Event event){
      _userRepo.requestDeleteEvents(event);
    });
    triggerOnConditionalAction(callAuthAction, (_) async{
      await _userRepo.callAuthService().then((value) {
        _redirectURL = "value";
      });
      return true;
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
      return _userRepo.createUser(_selectedRole, _selectedTags).then(
              (value) {
                _user = value;
                _selectedRole = null;
                _selectedTags = List();
                _searchTags = _allTags;
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

  String get followedEventError => _followedEventError;
  String get createdEventError => _createdEventError;
  bool get isFollowedLoading => _isFollowedLoading;
  bool get isCreatedLoading => _isCreatedLoading;

  String get redirectURL => _redirectURL;

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
