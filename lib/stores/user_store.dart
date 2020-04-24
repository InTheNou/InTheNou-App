import 'dart:io';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_manager.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:InTheNou/repos/tag_repo.dart';
import 'package:InTheNou/repos/user_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:google_sign_in/google_sign_in.dart';

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
  Future<Cookie> _session;
  Future<GoogleSignInAccount> _account;

  Future<bool> accountCreationFinished = Future.value(false);

  DialogService _dialogService = DialogService();

  UserStore() {
     _tagRepo.getAllTags().then((tags) {
       _allTags = new Map<Tag,bool>.fromIterable(tags,
           key: (tag) => tag,
           value: (tag) => false
       );
       if(_searchTags.isEmpty){
         _searchTags = new Map.from(_allTags);
       }
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
     triggerOnAction(addTagAction, (Tag tag) {

       _tagRepo.addTag([tag]);
     });
     triggerOnAction(removeTagAction, (Tag tag) async {
       DialogResponse response = await _dialogService.showDialog(
           type: DialogType.ImportantAlert,
           title: "Remove Tag Confirmation",
           description: "");
       _tagRepo.removeTag([tag]);
     });
    triggerOnConditionalAction(callAuthAction, (_) async{

      return _userRepo.logIn().then((uid) async{
        // Get the latest userAccount object
        getAccount();
        if(uid != null){
          if(uid == -1){
            return false;
          }
          return _userRepo.getUserInfo(uid).then((user){
            loginUser = Future.value(user);
            print(user);
            _user = user;
            return true;
          }).catchError((e){
            _showLoginError("Error Logging in", e);
            return true;
          });
        }
        loginUser = Future.value(null);
        return true;
      }).catchError((e){
        // Get the latest userAccount object, event if the login failed since
        // the google signIn might have gone through.
        getAccount();
        _showLoginError("Logging in", e);
        return true;
      });
    });
     triggerOnAction(fetchSession, (_) {
      _session = getSession();
    });
    triggerOnAction(googleSignOut, (_) {
      _account = _userRepo.googleSignOut();
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
      trigger();
    });
    triggerOnAction(toggleTagAction, (MapEntry<Tag,bool> tag) {
      if (tag.value){
        if(_selectedTags.length > 4){
          _dialogService.showDialog(
              type: DialogType.Alert,
              title: "Tag Limit Reached",
              description: "You have reached the limit of 5 Tags for the "
                  "Account Creation.");
          return;
        } else {
          _selectedTags.add(tag.key);
        }
      } else {
        _selectedTags.remove(tag.key);
      }
      if(_searchTags.containsKey(tag.key)){
        _searchTags.update(tag.key, (value) => tag.value);
        _allTags.update(tag.key, (value) => tag.value);
      }
    });
    triggerOnConditionalAction(createUserAction, (_) async {
      DialogResponse response = await _dialogService.showDialog(
        type: DialogType.ImportantAlert,
        title: "Account Creation",
        description: "Your account will be created now with these "
            "initial selected interest Tags.",
        dismissible: false,
        primaryButtonTitle: "CONFIRM",
        secondaryButtonTitle: "CANCEL"
      );
      if(!response.result){
        return false;
      }
      _dialogService.showFullscreenLoadingDialog(
          description: "We are getting your account ready!");
      trigger();
      return _userRepo.signUp(_selectedTags).then((value) {
        _dialogService.dialogComplete(DialogResponse(result: true));
        _user = value;
        _selectedRole = null;
        _selectedTags = List();
        _searchTags = _allTags;
        accountCreationFinished = Future.value(true);
        return true;
      }).catchError((e){
        _dialogService.dialogComplete(DialogResponse(result: true));
        _showLoginError("Creating Account Failed", e);
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

  void _showLoginError(String title, dynamic e){
    String error;
    if (e.runtimeType == PlatformException) {
      if (e.code == GoogleSignIn.kNetworkError) {
        error = "Unable to sign in, Network unavailable.";
      } else {
        error = "Internal app error while Signing in";
      }
    } else if (e is DioError){
      error = e.toString();
    } else {
      error = e.toString();
    }
    _dialogService.showDialog(
        type: DialogType.Error,
        title: title,
        description: error);
  }

  ///
  /// This method calls the backend to get the information on the uer after
  /// it has logged in with Google.
  /// The [Future] can return a Null if the user is new to the system.
  /// Otherwise it return the full User information
  Future<User> getUser() async{
    return _userRepo.getUserFromPrefs().then((value) {
      _user = value;
      print("getuser");
      print(_user);
      trigger();
      return _user;
    }).catchError((e){
      _dialogService.showDialog(
          type: DialogType.Error,
          title: "Local sign in failed",
          description: "Unable to retrieve local User Info");
    });
  }

  ///
  /// Method gets the Session saved locally, if there is one.
  /// If there is none or the Session found is invalid, then Null is returned
  Future<Cookie> getSession() async {
    return _userRepo.getSession();
  }

  Future<GoogleSignInAccount> getAccount() async {
    _account = _userRepo.getGoogleAccount();
    return _account;
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

  Future<Cookie> get session => _session;
  Future<GoogleSignInAccount> get account => _account;

}
//Profile Actions
final flux.Action refreshFollowedAction = new flux.Action();
final flux.Action refreshHistoryAction = new flux.Action();
final flux.Action refreshCreatedAction = new flux.Action();
final flux.Action<Event> cancelEventAction = new flux.Action();
final flux.Action getMyTagsAction = new flux.Action();

final flux.Action<Tag> addTagAction = new flux.Action();
final flux.Action<Tag> removeTagAction = new flux.Action();

//AccountCreation and Auth Actions
final flux.Action fetchSession = new flux.Action();
final flux.Action callAuthAction = new flux.Action();
final flux.Action googleSignOut = new flux.Action();
final flux.Action<UserRole> selectRoleAction = new flux.Action();
final flux.Action<String> searchedTagAction = new flux.Action();
final flux.Action<MapEntry<Tag,bool>> toggleTagAction = new flux.Action();
final flux.Action createUserAction = new flux.Action();

final flux.Action changeUserPrivilegeAction = new flux.Action();
