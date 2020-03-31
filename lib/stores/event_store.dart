import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


class EventFeedStore extends flux.Store{

  static final flux.StoreToken eventFeedToken = new flux.StoreToken(
      new EventFeedStore());
  static final EventsRepo _eventsRepo = new EventsRepo();

  List<Event> _personalSearch = new List();
  String _personalSearchKeyword;
  bool _isPerSearching = false;
  double perScrollPos = 0.0;

  List<Event> _generalSearch = new List();
  String _generalSearchKeyword;
  bool _isGenSearching = false;
  double genScrollPos = 0.0;

  Event _eventDetail;

  Event eventDismissed;
  int perDismissEventIndex;
  int genDismissEventIndex;

  final List<bool> isLoading = [false, false, false];
  List<String> _errors = List(3);

  EventFeedStore(){

    triggerOnConditionalAction(searchFeedAction, (MapEntry<FeedType, String> search){
      if (search.key == FeedType.PersonalFeed) {
        isLoading[0] = true;
        trigger();
        _personalSearchKeyword = search.value;
        return _eventsRepo.searchPerEvents(search.value,0, EVENTS_TO_FETCH)
            .then((List<Event> value) {
          _personalSearch = value;
          isLoading[0] = false;
          return true;
        }).catchError((error){
          isLoading[0] = false;
          _errors[0] = error.toString();
          return true;
        });
      } else {
        isLoading[1] = true;
        trigger();
        _generalSearchKeyword = search.value;
        return _eventsRepo.searchGenEvents(search.value,0, EVENTS_TO_FETCH)
            .then((List<Event> value) {
          _generalSearch = value;
          isLoading[1] = false;
          return true;
        }).catchError((error){
          isLoading[1] = false;
          _errors[1] = error.toString();
          return true;
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
    triggerOnConditionalAction(getAllEventsAction, (FeedType feed){
      if (feed == FeedType.PersonalFeed) {
        isLoading[0] = true;
        trigger();
        return _eventsRepo.getPerEvents(_personalSearch.length, EVENTS_TO_FETCH)
            .then((List<Event> value) {
          _personalSearch = value;
          isLoading[0] = false;
          return true;
        }).catchError((error){
          isLoading[0] = false;
          _setError(feed, error.toString());
          return true;
        });
      } else {
        isLoading[1] = true;
        trigger();
        return _eventsRepo.getGenEvents(_generalSearch.length, EVENTS_TO_FETCH)
            .then((List<Event> value) {
          _generalSearch = value;
          isLoading[1] = false;
          return true;
        }).catchError((error){
          isLoading[1] = false;
          _setError(feed, error.toString());
          return true;
        });
      }
    });
    triggerOnConditionalAction(openEventDetail, (int eventID){
      return _eventsRepo.getEvent(eventID).then((Event value) {
        _eventDetail = value;
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
          NotificationHandler.checkNotifications(event.value);
          return false;
        } else {
          // Revert all changes
          _modifyFollowStatus(event.value, false);
          _setError(event.key, "Error Following Event please try again later.");
          return true;
        }
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
          NotificationHandler.cancelNotification(event.value);
          int i = _personalSearch.indexOf(event.value);
          return false;
        } else{
          // Revert all changes
          _modifyFollowStatus(event.value, true);
          _setError(event.key, "Error UnFollowing Event please try again later"
              ".");
          return true;
        }
      }).catchError((error){
        _modifyFollowStatus(event.value, true);
        _setError(event.key, error.toString());
        return true;
      });
    });
    triggerOnAction(dismissEventAction, (int eventUID){
      // Remove the event from the list of events for the Personal Feed
      // And save the event in case the user hits Undo
      perDismissEventIndex = _personalSearch.indexWhere((event) =>
        event.UID == eventUID);
      if (perDismissEventIndex != -1){
        eventDismissed = _personalSearch[perDismissEventIndex];
        _personalSearch.removeAt(perDismissEventIndex);
      }

      // Remove it also from the General Feed
      // Saved here again just in case it's not in the Personal Feed
      genDismissEventIndex = _generalSearch.indexWhere((event) =>
        event.UID == eventUID);
      if (genDismissEventIndex != -1){
        eventDismissed = _generalSearch[genDismissEventIndex];
        _generalSearch.removeAt(genDismissEventIndex);
      }
    });
    triggerOnAction(undoDismissAction, (_){
      // Use clicked Undo, bring back the Event to the Feeds
      if (perDismissEventIndex != -1){
        _personalSearch.insert(perDismissEventIndex, eventDismissed);
        perDismissEventIndex = -1;
      }
      if (genDismissEventIndex != -1){
        _generalSearch.insert(genDismissEventIndex, eventDismissed);
        genDismissEventIndex = -1;
      }
    });
    triggerOnConditionalAction(confirmDismissAction, (FeedType type){
      return _eventsRepo.requestDismissEvent(eventDismissed.UID).then((value){
        if(value){
          perDismissEventIndex = -1;
          genDismissEventIndex = -1;
          eventDismissed = null;
          return false;
        } else {
          if (perDismissEventIndex != -1){
            _personalSearch.insert(perDismissEventIndex, eventDismissed);
            perDismissEventIndex = -1;
          }
          if (genDismissEventIndex != -1){
            _generalSearch.insert(genDismissEventIndex, eventDismissed);
            genDismissEventIndex = -1;
          }
          perDismissEventIndex = -1;
          genDismissEventIndex = -1;
          eventDismissed = null;
          _setError(type, "Error Dimsissing Event please try again later.");
          return true;
        }
      }).catchError((error){
        _setError(type, error.toString());
      });
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

  void _modifyFollowStatus(Event event, bool status){
    int i = _personalSearch.indexOf(event);
    if (i != -1){
      _personalSearch[i].followed = status;
    }
    i = _generalSearch.indexOf(event);
    if (i != -1){
      _generalSearch[i].followed = status;
    }
    // Also change the detailed in case it is showing
    if (_eventDetail != null && _eventDetail.UID == event.UID){
      _eventDetail.followed = status;
    }
  }

  int eventCount(FeedType feed){
    if (feed == FeedType.PersonalFeed) {
      return _personalSearch.length;
    } else {
      return _generalSearch.length;
    }
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

  Event feedEvent(FeedType feed, int index){
    if (feed == FeedType.PersonalFeed) {
      return _personalSearch[index];
    } else {
      return _generalSearch[index];
    }
  }

  bool isFeedLoading(FeedType type){
    switch (type){
      case FeedType.PersonalFeed:
        return isLoading[0];
        break;
      case FeedType.GeneralFeed:
        return isLoading[1];
        break;
      case FeedType.Detail:
        return isLoading[2];
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

  List<Event> get personalSearch => new List.unmodifiable(_personalSearch);
  List<Event> get generalSearch => new List.unmodifiable(_generalSearch);
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
