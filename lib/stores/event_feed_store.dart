import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:shared_preferences/shared_preferences.dart';


class EventFeedStore extends flux.Store{

  static final flux.StoreToken eventFeedToken = new flux.StoreToken(
      new EventFeedStore());
  static final EventsRepo _eventsRepo = new EventsRepo();
  SharedPreferences _prefs;

  Future<List<Event>> _personalSearch;
  String _personalSearchKeyword;
  bool _isPerSearching = false;

  Future<List<Event>> _generalSearch;
  String _generalSearchKeyword;
  bool _isGenSearching = false;

  Event _eventDetail;

  Event eventDismissed;
  int perDismissEventIndex;
  int genDismissEventIndex;

  List<double> _scrollPosition = [0.0,0.0,0.0];
  List<bool> _isLoading = [false, false, false];
  List<String> _errors = List(3);

  bool _detailNeedsToClose=false;

  EventFeedStore() {
    SharedPreferences.getInstance().then((value) => _prefs = value);
    _getAllEvents(FeedType.PersonalFeed);
    _getAllEvents(FeedType.GeneralFeed);
    triggerOnConditionalAction(searchFeedAction, (MapEntry<FeedType, String> search){
      if (search.key == FeedType.PersonalFeed) {
        _personalSearch = Future.value(null);
        trigger();
        _personalSearchKeyword = search.value;
        return _eventsRepo.searchPerEvents(search.value,0, EVENTS_TO_FETCH)
            .then((events) {
          _personalSearch = Future.value(events);
          return true;
        }).catchError((e){
          _personalSearch = Future.error(e);
        });
      } else {
        _generalSearch = Future.value(null);
        trigger();
        return _eventsRepo.searchGenEvents(search.value,0, EVENTS_TO_FETCH)
            .then((events) {
          _generalSearch = Future.value(events);
          return true;
        }).catchError((e){
          _generalSearch = Future.error(e);
        });
      }
    });
    triggerOnAction(setFeedSearching, (MapEntry<FeedType, bool> search){
      if (search.key == FeedType.PersonalFeed) {
        _isPerSearching = search.value;
      } else {
        _isGenSearching = search.value;
      }
    });
    triggerOnConditionalAction(getAllEventsAction, (FeedType feed) {
      return _getAllEvents(feed);
    });
    triggerOnConditionalAction(openEventDetail, (int eventID){
      if(_eventDetail !=null && _eventDetail.UID == eventID){
        return true;
      }
      _eventDetail = null;
      trigger();
      return _eventsRepo.getEvent(eventID).then((Event value) {
        _eventDetail = value;
        return true;
      }).catchError((error){
        _setError(FeedType.Detail, error.toString());
        return true;
      });
    });
    triggerOnAction(clearSearchKeywordAction, (FeedType feed){
      if (feed == FeedType.PersonalFeed) {
        _personalSearchKeyword = "";
      } else {
        _generalSearchKeyword = "";
      }
    });
    triggerOnConditionalAction(followEventAction, (MapEntry<FeedType, Event> event){
      // Follow locally first just to show the change tot he user
      _modifyFollowStatus(event.value, true);
      trigger();

      // If the server was able to follow don't send another change trigger,
      // but run the scheduling of Default notifications and check in case
      // the Smart Notification needs to be scheduled.
      return _eventsRepo.requestFollowEvent(event.value.UID).then((bool followed) {
        if (followed){
          if(event.value.startDateTime.isBefore(DateTime.now())){
            _setError(event.key, "You have Followed an event that has already"
                " started. Your interest in the event will be recorded but "
                "you will not recive notifications for it.");
          }
          NotificationHandler.checkNotifications(event.value);
        } else {
          // Revert all changes
          _modifyFollowStatus(event.value, false);
          _setError(event.key, "Error Following Event please try again later.");
        }
        return true;
      }).catchError((error){
        _modifyFollowStatus(event.value, false);
        _setError(event.key, error.toString());
        return true;
      });
    });
    triggerOnConditionalAction(unFollowEventAction, (MapEntry<FeedType, Event> event){
      // Unfollow locally first just to show the change tot he user
      _modifyFollowStatus(event.value, false);
      trigger();

      // If the server was able to unfollow, cancel notifications
      return _eventsRepo.requestUnFollowEvent(event.value.UID).then((bool
      unfollowed) {
        if (unfollowed){
          if(event.value.startDateTime.isBefore(DateTime.now())){
            _setError(event.key, "You have UnFollowed an event that has already"
                " started. Your disinterest in the event will be recorded.");
          }
          NotificationHandler.cancelNotification(event.value);
        } else{
          // Revert all changes
          _modifyFollowStatus(event.value, true);
          _setError(event.key, "Error UnFollowing Event please try again later.");
        }
        return true;
      }).catchError((error){
        _modifyFollowStatus(event.value, true);
        _setError(event.key, error.toString());
        return true;
      });
    });
    triggerOnAction(dismissEventAction, (int eventUID) async{
      // Remove the event from the list of events for the Personal Feed
      // And save the event in case the user hits Undo
      var pEvents = await _personalSearch;
      perDismissEventIndex = pEvents.indexWhere((event) =>
        event.UID == eventUID);
      if (perDismissEventIndex != -1){
        eventDismissed = pEvents[perDismissEventIndex];
        pEvents.removeAt(perDismissEventIndex);
        _personalSearch = Future.value(pEvents);
      }
//
//      // Remove it also from the General Feed
//      // Saved here again just in case it's not in the Personal Feed
      var gEvents = await _generalSearch;
      genDismissEventIndex = gEvents.indexWhere((event) =>
        event.UID == eventUID);
      if (genDismissEventIndex != -1){
        eventDismissed = gEvents[genDismissEventIndex];
        gEvents.removeAt(genDismissEventIndex);
        _generalSearch = Future.value(gEvents);
      }
    });
    triggerOnAction(undoDismissAction, (_) async{
      // Use clicked Undo, bring back the Event to the Feeds
      if (perDismissEventIndex != -1){
        var pEvents = await _personalSearch;
        pEvents.insert(perDismissEventIndex, eventDismissed);
        _personalSearch = Future.value(pEvents);
        perDismissEventIndex = -1;
      }
      if (genDismissEventIndex != -1){
        var gEvents = await _generalSearch;
        gEvents.insert(genDismissEventIndex, eventDismissed);
        _generalSearch = Future.value(gEvents);
        genDismissEventIndex = -1;
      }
    });
    triggerOnConditionalAction(confirmDismissAction, (FeedType type){
      if(type == FeedType.Detail){
        _isLoading[2] = true;
        trigger();
      }
      return _eventsRepo.requestDismissEvent(eventDismissed.UID).then((value){
        if(value){
          if(type == FeedType.Detail){
            _isLoading[2] = false;
            _detailNeedsToClose = true;
            trigger();
          }
          perDismissEventIndex = -1;
          genDismissEventIndex = -1;
          if(eventDismissed.startDateTime.isBefore(DateTime.now())){
            _setError(type, "You have UnFollowed an event that has already"
                " started. Your interest in the event will be recorded.");
          }
          eventDismissed = null;
          return true;
        } else {
          _reInsertDismissed();
          _setError(type, "Error Dimsissing Event please try again later.");
          return true;
        }
      }).catchError((error){
        if(type == FeedType.Detail){
          _isLoading[2] = false;
        }
        _reInsertDismissed();
        _setError(type, error.toString());
        return true;
      });
    });
     triggerOnAction(cancelEventAction, (_){
       _getAllEvents(FeedType.PersonalFeed);
       _getAllEvents(FeedType.GeneralFeed);
     });
    triggerOnAction(clearErrorAction, (FeedType type){
      switch (type){
        case FeedType.PersonalFeed:
          _errors[0] = null;
          break;
        case FeedType.GeneralFeed:
          _errors[1] = null;
          break;
        case FeedType.Detail:
          _errors[2] = null;
          break;
      }
    });
  }

  Future<bool> _getAllEvents(FeedType feed) async{
    if (feed == FeedType.PersonalFeed) {
      _personalSearch = Future.value(null);
      trigger();
      return _eventsRepo.getPerEvents(0, EVENTS_TO_FETCH).then((value) {
        _personalSearch = Future.value(value);
        trigger();
        return true;
      }).catchError((e){
        _personalSearch = Future.error(e);
      });
    } else {
      _generalSearch = Future.value(null);
      trigger();
      return _eventsRepo.getGenEvents(0, EVENTS_TO_FETCH).then((value) {
        _generalSearch = Future.value(value);
        trigger();
        return true;
      }).catchError((e){
        _generalSearch = Future.error(e);
      });
    }
    return true;
  }

  void _modifyFollowStatus(Event event, bool status) async{
    var pEvents = await _personalSearch;
    int i = pEvents.indexOf(event);
    if (i != -1){
      pEvents[i].followed = status;
      _personalSearch = Future.value(pEvents);
    }
    var gEvents = await _generalSearch;
    i = gEvents.indexOf(event);
    if (i != -1){
      gEvents[i].followed = status;
      _generalSearch = Future.value(gEvents);
    }
    // Also change the detailed in case it is showing
    if (_eventDetail != null && _eventDetail.UID == event.UID){
      _eventDetail.followed = status;
    }
  }

  void _reInsertDismissed() async{
    if (perDismissEventIndex != -1){
      var pEvents = await _personalSearch;
      pEvents.insert(perDismissEventIndex, eventDismissed);
      _personalSearch = Future.value(pEvents);
      perDismissEventIndex = -1;
    }
    if (genDismissEventIndex != -1){
      var gEvents = await _generalSearch;
      gEvents.insert(genDismissEventIndex, eventDismissed);
      _generalSearch = Future.value(gEvents);
      genDismissEventIndex = -1;
    }
    perDismissEventIndex = -1;
    genDismissEventIndex = -1;
    eventDismissed = null;
  }

  bool isSearching(FeedType feed){
    if (feed ==  FeedType.PersonalFeed) {
      return _isPerSearching;
    } else {
      return _isGenSearching;
    }
  }

  String searchKeyword(FeedType feed){
    if (feed ==  FeedType.PersonalFeed) {
      return _personalSearchKeyword;
    } else {
      return _generalSearchKeyword;
    }
  }

  bool isFeedLoading(FeedType type){
    switch (type){
      case FeedType.PersonalFeed:
        return _isLoading[0];
        break;
      case FeedType.GeneralFeed:
        return _isLoading[1];
        break;
      case FeedType.Detail:
        return _isLoading[2];
        break;
      default:
        return false;
        break;
    }
  }

  String getError(FeedType type){
    switch (type){
      case FeedType.PersonalFeed:
        return _errors[0];
        break;
      case FeedType.GeneralFeed:
        return _errors[1];
        break;
      case FeedType.Detail:
        return _errors[2];
        break;
      default:
        return null;
        break;
    }
  }

  void _setError(FeedType type, String error){
    switch (type){
      case FeedType.PersonalFeed:
        _errors[0] = error;
        break;
      case FeedType.GeneralFeed:
        _errors[1] = error;
        break;
      case FeedType.Detail:
        _errors[2] = error;
        break;
    }
  }

  double getScrollPos(FeedType type){
    switch (type){
      case FeedType.PersonalFeed:
        return _scrollPosition[0];
        break;
      case FeedType.GeneralFeed:
        return _scrollPosition[1];
        break;
      case FeedType.Detail:
        return _scrollPosition[2];
        break;
    }
  }

  void setScrollPos(FeedType type, double pos){
    switch (type){
      case FeedType.PersonalFeed:
        _scrollPosition[0] = pos;
        break;
      case FeedType.GeneralFeed:
        _scrollPosition[1] = pos;
        break;
      case FeedType.Detail:
        _scrollPosition[2] = pos;
        break;
    }
  }

  int getDefaultNotification(){
    return _prefs.getInt(DEFAULT_NOTIFICATION_KEY);
  }
  String getSmartNotification(){
    return _prefs.getBool(SMART_NOTIFICATION_KEY)? "ON" : "OFF";
  }


  bool get detailNeedsToClose => _detailNeedsToClose;

  set detailNeedsToClose(bool value) {
    _detailNeedsToClose = value;
  }


  Future<List<Event>> get personalSearch => _personalSearch;
  Future<List<Event>> get generalSearch => _generalSearch;
  Event get eventDetail => _eventDetail;

}

final flux.Action<MapEntry<FeedType, String>> searchFeedAction = new flux
    .Action<MapEntry<FeedType, String>>();
final flux.Action<MapEntry<FeedType, bool>> setFeedSearching = new flux
    .Action<MapEntry<FeedType, bool>>();
final flux.Action<FeedType> clearSearchKeywordAction = new flux
    .Action<FeedType>();
final flux.Action<FeedType> getAllEventsAction = new flux.Action<FeedType>();
final flux.Action<int> openEventDetail = new flux.Action();
final flux.Action<MapEntry<FeedType, Event>> followEventAction = new flux.Action();
final flux.Action<MapEntry<FeedType, Event>> unFollowEventAction = new flux.Action();
final flux.Action<int> dismissEventAction = new flux
    .Action();
final flux.Action undoDismissAction = new flux.Action();
final flux.Action<FeedType> confirmDismissAction = new flux.Action();

final flux.Action<FeedType> clearErrorAction = new flux.Action();
