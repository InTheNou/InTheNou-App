import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/dialog_manager.dart';
import 'package:InTheNou/dialog_service.dart';
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

  Future<Event> _eventDetail;
  Future<bool> _detailNeedsToClose = Future.value(false);

  Event eventDismissed;
  int perDismissEventIndex;
  int genDismissEventIndex;

  List<double> _scrollPosition = [0.0,0.0,0.0];

  DialogService _dialogService = DialogService();

  EventFeedStore() {
    SharedPreferences.getInstance().then((value) => _prefs = value);
    _getAllEvents(FeedType.PersonalFeed);
    _getAllEvents(FeedType.GeneralFeed);
    triggerOnAction(searchFeedAction, (MapEntry<FeedType, String> search){
      if (search.key == FeedType.PersonalFeed) {
        _personalSearchKeyword = search.value;
        try{
          _personalSearch = _eventsRepo.searchPerEvents(search.value,0,
              PAGINATION_GET_ALL);
        } catch(e){
          _personalSearch = Future.error(e);
        }
      } else {
        _generalSearchKeyword = search.value;
        try{
          _generalSearch = _eventsRepo.searchGenEvents(search.value,0,
              PAGINATION_GET_ALL);
        } catch(e){
          _generalSearch = Future.error(e);
        }
      }
    });
    triggerOnAction(setFeedSearching, (MapEntry<FeedType, bool> search){
      if (search.key == FeedType.PersonalFeed) {
        _isPerSearching = search.value;
      } else {
        _isGenSearching = search.value;
      }
    });
    triggerOnAction(getAllEventsAction, (FeedType feed) {
      _getAllEvents(feed);
    });
    triggerOnAction(openEventDetail, (int eventID) async {
      var currentEvent = await _eventDetail;
      if (currentEvent == null || currentEvent.UID != eventID) {
        trigger();
        _eventDetail = _eventsRepo.getEvent(eventID);
      }
    });
    triggerOnAction(clearSearchKeywordAction, (FeedType feed){
      if (feed == FeedType.PersonalFeed) {
        _personalSearchKeyword = "";
      } else {
        _generalSearchKeyword = "";
      }
    });
    triggerOnAction(followEventAction, (MapEntry<FeedType, Event> event){
      // Follow locally first just to show the change tot he user
      _modifyFollowStatus(event.value, true);
      trigger();
      if(event.value.endDateTime.isBefore(DateTime.now())){
        _dialogService.showDialog(
            type: DialogType.Alert,
            title: "Following an event that has ended",
            description: "The event you are trying to Follow has eneded. You "
                "can only Follow event that has not ended.",
            primaryButtonTitle: "OK");
        return;
      }
      if(event.value.startDateTime.isBefore(DateTime.now())){
        _dialogService.showDialog(
            type: DialogType.Alert,
            title: "Following an event that has started",
            description: "You have Followed an event that has already"
                " started. Your interest in the event will be recorded but "
                "you will not recieve a notification.",
            primaryButtonTitle: "OK");
      }

      // If the server was able to follow, don't send another change trigger,
      // but run the scheduling of Default notifications and check in case
      // the Smart Notification needs to be scheduled.
      _eventsRepo.requestFollowEvent(event.value.UID).then((bool followed) {
        if (followed){
          NotificationHandler.checkNotifications(event.value);
        } else {
          // If the server was able to follow, revert local follow
          _modifyFollowStatus(event.value, false);
          _dialogService.showDialog(
              type: DialogType.Error,
              title: "Unable to Follow",
              description: "Error Following Event please try again later.");
        }
      }).catchError((error){
        _modifyFollowStatus(event.value, false);
        _dialogService.showDialog(
            type: DialogType.Error,
            title: "Unable to Follow",
            description: error.toString());
      });
    });
    triggerOnAction(unFollowEventAction, (MapEntry<FeedType, Event> event){
      // Unfollow locally first just to show the change tot he user
      _modifyFollowStatus(event.value, false);
      trigger();
      if(event.value.endDateTime.isBefore(DateTime.now())){
        _dialogService.showDialog(
            type: DialogType.Alert,
            title: "Unfollowing an event that has ended",
            description: "The event you are trying to Unfollow has eneded. "
                "You can only Unfollow event that has not ended, as it has "
                "been moved to your History.",
            primaryButtonTitle: "OK");
        return;
      }
      if(event.value.startDateTime.isBefore(DateTime.now())){
        _dialogService.showDialog(
            type: DialogType.Alert,
            title: "Unfollowing an event that has started",
            description: "You have Unfollowed an event that has already"
                " started. Your disinterest in the event will be recorded.",
            primaryButtonTitle: "OK");
      }

      // If the server was able to unfollow, cancel notifications
      _eventsRepo.requestUnFollowEvent(event.value.UID).then((bool unfollowed) {
        if (unfollowed){
          NotificationHandler.cancelNotification(event.value);
        } else{
          // Revert all changes
          _modifyFollowStatus(event.value, true);
          _dialogService.showDialog(
              type: DialogType.Error,
              title: "Unable to Unfollow",
              description: "Error Unfollowing Event please try again later.",
              primaryButtonTitle: "OK");
        }
      }).catchError((error){
        _modifyFollowStatus(event.value, true);
        _dialogService.showDialog(
            type: DialogType.Error,
            title: "Unable to Unfollow",
            description: error.toString(),
            primaryButtonTitle: "OK");
      });
    });
    triggerOnAction(dismissEventAction, (Event event) async{
      // Check if the event is followed currently and show an Alert to the
      // user to prevent them from dismissing a followed event.
      if(event.followed){
        _showDismissUnableDialog();
        return;
      }
      if(event.endDateTime.isBefore(DateTime.now())){
        _dialogService.showDialog(
            type: DialogType.Alert,
            title: "Dismissing an event that has ended",
            description: "The event you are trying to Dismiss has eneded. "
                "You can only Dismiss event that has not ended.",
            primaryButtonTitle: "OK");
        return;
      }
      // Remove the event from the list of events for the Personal Feed
      // And save the event in case the user hits Undo
      var pEvents = await _personalSearch;
      perDismissEventIndex = pEvents.indexWhere((feedEvent) =>
        feedEvent.UID == event.UID);
      if (perDismissEventIndex != -1){
        eventDismissed = pEvents[perDismissEventIndex];
        pEvents.removeAt(perDismissEventIndex);
        _personalSearch = Future.value(pEvents);
      }
//
//      // Remove it also from the General Feed
//      // Saved here again just in case it's not in the Personal Feed
      var gEvents = await _generalSearch;
      genDismissEventIndex = gEvents.indexWhere((feedEvent) =>
        feedEvent.UID == event.UID);
      if (genDismissEventIndex != -1){
        eventDismissed = gEvents[genDismissEventIndex];
        gEvents.removeAt(genDismissEventIndex);
        _generalSearch = Future.value(gEvents);
      }
    });
    triggerOnAction(undoDismissAction, (_) async{
      // User clicked Undo, bring back the Event to the Feeds
      _reInsertDismissed();
    });
    triggerOnAction(confirmDismissAction, (FeedType type){
      if(type == FeedType.Detail){
        _dialogService.showLoadingDialog(
            title: "Dismissing the Event"
        );
      } else {
        if(eventDismissed.startDateTime.isBefore(DateTime.now())){
          _dialogService.showDialog(
              type: DialogType.Alert,
              title: "Dismissing an event that has started",
              description: "You have Dismissed an event that has already"
                  " started. Your disinterest in the event will be recorded.",
              primaryButtonTitle: "OK"
          );
        }
      }
      _eventsRepo.requestDismissEvent(eventDismissed.UID).then((value){
        // Dismiss the loading dialog
        if(type == FeedType.Detail){
          _dialogService.dialogComplete(DialogResponse(result: true));
        }
        if(value){
          if(type == FeedType.Detail){
            _detailNeedsToClose = Future.value(true);
            trigger();
          }
          perDismissEventIndex = -1;
          genDismissEventIndex = -1;
          eventDismissed = null;
        } else {
          _showDismissErrorDialog("Error Dimsissing Event please try again "
              "later.");
          _reInsertDismissed();
        }
      }).catchError((error){
        _showDismissErrorDialog(error.toString());
        _reInsertDismissed();
      });
    });
     triggerOnAction(cancelEventAction, (_){
       _getAllEvents(FeedType.PersonalFeed);
       _getAllEvents(FeedType.GeneralFeed);
     });
  }

  Future _getAllEvents(FeedType feed) async{
    if (feed == FeedType.PersonalFeed) {
      _personalSearch = _eventsRepo.getPerEvents(0, PAGINATION_GET_ALL);
    } else {
      _generalSearch = _eventsRepo.getGenEvents(0, PAGINATION_GET_ALL);
    }
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
    var dEvent = await _eventDetail;

    if (dEvent != null && dEvent.UID == event.UID){
      dEvent.followed = status;
      _eventDetail = Future.value(dEvent);
    }
  }

  void _reInsertDismissed() async{
    if (perDismissEventIndex != -1){
      var pEvents = await _personalSearch;
      pEvents.insert(perDismissEventIndex, eventDismissed);
      _personalSearch = Future.value(pEvents);
    }
    if (genDismissEventIndex != -1){
      var gEvents = await _generalSearch;
      gEvents.insert(genDismissEventIndex, eventDismissed);
      _generalSearch = Future.value(gEvents);
    }
    perDismissEventIndex = -1;
    genDismissEventIndex = -1;
    eventDismissed = null;
    trigger();
  }

  void _showDismissUnableDialog(){
    _dialogService.showDialog(
        type: DialogType.Alert,
        title: "Unable to Dismiss",
        description: "Please unfollow the Event before dismissing it.",
        primaryButtonTitle: "OK"
    );
  }

  void _showDismissErrorDialog(String message){
    _dialogService.showDialog(
        type: DialogType.Error,
        title: "Unable to Dismiss",
        description: message,
        primaryButtonTitle: "OK"
    );
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


  Future<bool> get detailNeedsToClose => _detailNeedsToClose;

  set detailNeedsToClose(Future<bool> value) {
    _detailNeedsToClose = value;
  }

  Future<List<Event>> get personalSearch => _personalSearch;
  Future<List<Event>> get generalSearch => _generalSearch;
  Future<Event> get eventDetail => _eventDetail;

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
final flux.Action<Event> dismissEventAction = new flux
    .Action();
final flux.Action undoDismissAction = new flux.Action();
final flux.Action<FeedType> confirmDismissAction = new flux.Action();

