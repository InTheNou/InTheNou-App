import 'package:InTheNou/assets/values.dart';
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
  Event _perEventDetail;
  double perScrollPos = 0.0;

  List<Event> _generalSearch = new List();
  String _generalSearchKeyword;
  bool _isGenSearching = false;
  Event _genEventDetail;
  double genScrollPos = 0.0;

  Event eventDismissed;
  int perDismissEventIndex;
  int genDismissEventIndex;

  EventFeedStore(){

    triggerOnAction(searchFeedAction, (MapEntry<FeedType, String> search){
      if (search.key == FeedType.PersonalFeed) {
        _personalSearchKeyword = search.value;
        _personalSearch = (_eventsRepo.searchPerEvents(0, search.value, DateTime
            .now(), 0, EVENTS_TO_FETCH)
        );
      } else {
        _generalSearchKeyword = search.value;
        _generalSearch = (_eventsRepo.searchGenEvents(0, search.value, DateTime
            .now(), 0, EVENTS_TO_FETCH)
        );
      }
    });
    triggerOnAction(setFeedSearching, (MapEntry<FeedType, bool> search){
      if (search.key == FeedType.PersonalFeed) {
        _isPerSearching = search.value;
      } else {
        _isGenSearching = search.value;
      }
    });
    triggerOnAction(getAllEventsAction, (FeedType feed){
      if (feed == FeedType.PersonalFeed) {
        _personalSearch = _eventsRepo.getPerEvents(0,DateTime.now(),
            _personalSearch.length, EVENTS_TO_FETCH);
      } else {
        _generalSearch = _eventsRepo.getGenEvents(0,DateTime.now(),
            _generalSearch.length, EVENTS_TO_FETCH);
      }
    });
    triggerOnAction(openEventDetail, (MapEntry<FeedType, int> event){
      if (event.key == FeedType.PersonalFeed) {
        _perEventDetail = _eventsRepo.getEvent(0, event.value);
      } else {
        _genEventDetail = _eventsRepo.getEvent(0, event.value);
      }
    });
    triggerOnAction(clearSearchKeywordAction, (FeedType feed){
      if (feed == FeedType.PersonalFeed) {
        _personalSearchKeyword = "";
      } else {
        _generalSearchKeyword = "";
      }
    });
    triggerOnAction(followEventAction, (int eventUID){
      // If the server was able to unfollow, modify the events currently showing
      if (_eventsRepo.requestFollowEvent(0, eventUID)){
        int i = _personalSearch.indexWhere((event) => event.UID == eventUID);
        if (i != -1){
          _personalSearch[i].followed = true;
        }
        i = _generalSearch.indexWhere((event) => event.UID == eventUID);
        if (i != -1){
          _generalSearch[i].followed = true;
        }
        // Also change the detailed in case they are showing
        if (_perEventDetail != null && _perEventDetail.UID == eventUID){
          _perEventDetail.followed = true;
        }
        if (_genEventDetail != null && _genEventDetail.UID == eventUID){
          _genEventDetail.followed = true;
        }
      }
    });
    triggerOnAction(unFollowEventAction, (int eventUID){
      // If the server was able to unfollow, modify the events currently showing
      if (_eventsRepo.requestUnFollowEvent(0, eventUID)){
        int i = _personalSearch.indexWhere((event) => event.UID == eventUID);
        if (i != -1){
          _personalSearch[i].followed = false;
        }
        i = _generalSearch.indexWhere((event) => event.UID == eventUID);
        if (i != -1){
          _generalSearch[i].followed = false;
        }
        // Also change the detailed in case they are showing
        if (_perEventDetail != null && _perEventDetail.UID == eventUID){
          _perEventDetail.followed = false;
        }
        if (_genEventDetail != null && _genEventDetail.UID == eventUID){
          _genEventDetail.followed = false;
        }
      }
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
    triggerOnAction(confirmDismissAction, (_){
      _eventsRepo.requestDismissEvent(0, eventDismissed.UID);
      perDismissEventIndex = -1;
      genDismissEventIndex = -1;
      eventDismissed = null;
    });
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

  Event feedEvent(FeedType feed, int index){
    if (feed == FeedType.PersonalFeed) {
      return _personalSearch[index];
    } else {
      return _generalSearch[index];
    }
  }

  Event detailedEvent(FeedType feed){
    if (feed == FeedType.PersonalFeed) {
      return _perEventDetail;
    } else {
      return _genEventDetail;
    }
  }

  List<Event> get personalSearch => new List.unmodifiable(_personalSearch);
  List<Event> get generalSearch => new List.unmodifiable(_generalSearch);
  String get personalSearchKeyword => _personalSearchKeyword;
  String get generalSearchKeyword => _generalSearchKeyword;
  Event get perEventDetail => _perEventDetail;

}

final flux.Action<MapEntry<FeedType, String>> searchFeedAction = new flux
    .Action<MapEntry<FeedType, String>>();
final flux.Action<MapEntry<FeedType, bool>> setFeedSearching = new flux
    .Action<MapEntry<FeedType, bool>>();
final flux.Action<FeedType> clearSearchKeywordAction = new flux
    .Action<FeedType>();
final flux.Action<FeedType> getAllEventsAction = new flux.Action<FeedType>();
final flux.Action<MapEntry<FeedType, int>> openEventDetail =
    new flux.Action<MapEntry<FeedType, int>>();
final flux.Action<int> followEventAction = new flux.Action<int>();
final flux.Action<int> unFollowEventAction = new flux.Action<int>();
final flux.Action<int> dismissEventAction = new flux.Action<int>();
final flux.Action undoDismissAction = new flux.Action();
final flux.Action confirmDismissAction = new flux.Action();

