import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


class EventFeedStore extends flux.Store{

  static const EVENTS_TO_FETCH = 20;
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
  int dismissEventIndex;

  EventFeedStore(){

    triggerOnAction(searchFeedAction, (MapEntry<String, String> search){
      if (search.key == "personal") {
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
    triggerOnAction(setFeedSearching, (MapEntry<String, bool> search){
      if (search.key == "personal") {
        _isPerSearching = search.value;
      } else {
        _isGenSearching = search.value;
      }
    });
    triggerOnAction(getAllEventsAction, (String feed){
      if (feed == "personal") {
        _personalSearch = _eventsRepo.getPerEvents(0,DateTime.now(),
            _personalSearch.length, EVENTS_TO_FETCH);
      } else {
        _generalSearch = _eventsRepo.getGenEvents(0,DateTime.now(),
            _generalSearch.length, EVENTS_TO_FETCH);
      }
    });
    triggerOnAction(clearSearchKeywordAction, (String feed){
      if (feed == "personal") {
        _personalSearchKeyword = "";
      } else {
        _generalSearchKeyword = "";
      }
    });
    triggerOnAction(followEventAction, (int eventUID){
      _eventsRepo.requestFollowEvent(0, eventUID);
    });
    triggerOnAction(unFollowEventAction, (int eventUID){
      _eventsRepo.requestUnFollowEvent(0, eventUID);
    });
    triggerOnAction(dismissEventAction, (MapEntry<String, int> dismissal){
      if (dismissal.key == "personal") {
        dismissEventIndex = _personalSearch.indexWhere((event) => event.UID ==
            dismissal.value);
        eventDismissed = _personalSearch[dismissEventIndex];
        _personalSearch.removeAt(dismissEventIndex);
      } else {
        dismissEventIndex = _generalSearch.indexWhere((event) => event.UID ==
            dismissal.value);
        eventDismissed = _generalSearch[dismissEventIndex];
        _generalSearch.removeAt(dismissEventIndex);
      }

//      _eventsRepo.requestDismissEvent(0, eventUID);
    });
    triggerOnAction(undoDismissAction, (String feed){
      if (feed == "personal") {
        _personalSearch.insert(dismissEventIndex, eventDismissed);
        dismissEventIndex = 0;
        eventDismissed = null;
      } else {
        _generalSearch.insert(dismissEventIndex, eventDismissed);
        dismissEventIndex = 0;
        eventDismissed = null;
      }
    });
    triggerOnAction(confirmDismissAction, (_){
      _generalSearch.insert(dismissEventIndex, eventDismissed);
      _eventsRepo.requestDismissEvent(0, eventDismissed.UID);
      dismissEventIndex = 0;
      eventDismissed = null;
    });
  }

  int eventCount(String feed){
    if (feed == "personal") {
      return _personalSearch.length;
    } else {
      return _generalSearch.length;
    }
  }

  bool isSearching(String feed){
    if (feed == "personal") {
      return _isPerSearching;
    } else {
      return _isGenSearching;
    }
  }

  Event feedEvent(String feed, int index){
    if (feed == "personal") {
      return _personalSearch[index];
    } else {
      return _generalSearch[index];
    }
  }

  List<Event> get personalSearch => new List.unmodifiable(_personalSearch);
  List<Event> get generalSearch => new List.unmodifiable(_generalSearch);
  String get personalSearchKeyword => _personalSearchKeyword;
  String get generalSearchKeyword => _generalSearchKeyword;

}

final flux.Action<MapEntry<String, String>> searchFeedAction = new flux
    .Action<MapEntry<String, String>>();
final flux.Action<MapEntry<String, bool>> setFeedSearching = new flux
    .Action<MapEntry<String, bool>>();
final flux.Action<String> clearSearchKeywordAction = new flux
    .Action<String>();
final flux.Action<String> getAllEventsAction = new flux.Action<String>();
final flux.Action<int> followEventAction = new flux.Action<int>();
final flux.Action<int> unFollowEventAction = new flux.Action<int>();
final flux.Action<MapEntry<String, int>> dismissEventAction = new flux.Action<MapEntry<String, int>>();
final flux.Action<String> undoDismissAction = new flux.Action<String>();
final flux.Action confirmDismissAction = new flux.Action();

