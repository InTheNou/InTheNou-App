import 'dart:convert';
import 'dart:async';
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:InTheNou/repos/user_repo.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';

class BackgroundHandler {

  static SharedPreferences _prefs;

  /// Configure the BackgroundFetch library.
  ///
  /// It creates a background process that is initialized every
  /// [BackgroundFetchConfig.minimumFetchInterval] and calls the function
  /// [onBackgroundFetch]. The SmartNotification functionality gets handled
  /// every time this initiated and it it handled in [_doSmartNotification].
  /// This method  can also schedule any other background tasks needed, be
  /// it one-hot or recurring. Here the Recommendation feature handled by
  /// the [_doRecommendation] task.
  ///
  /// The variable [BackgroundFetchConfig.stopOnTerminate] makes these tasks to
  /// operate when the app is not active.
  /// [BackgroundFetchConfig.enableHeadless] makes it so that a headless
  /// background task [onBackgroundFetch] is executed.
  static Future<void> initBackgroundTasks() async {
    BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 15,
      forceAlarmManager: true,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.ANY,
    ), onBackgroundFetch).then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });

    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.inthenou.app.reccomendation",
        delay: 60000,
        periodic: true,
        forceAlarmManager: true,
        stopOnTerminate: false,
        enableHeadless: true
    )).then((value) {
      print('[reccomendation] started: $value');
    });

    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.inthenou.app.cleanup",
        delay: 86400000,
        periodic: true,
        forceAlarmManager: false,
        stopOnTerminate: false,
        enableHeadless: true
    )).then((value) {
      print('[cleanup] started: $value');
    });
  }

  /// This is the fetch-event callback.
  ///
  /// IT handles all the background tasks scheduled manually or the default
  /// one. They get identified by [taskId] set when the task was initiated.
  static void onBackgroundFetch(String taskId) async {
    _prefs = await SharedPreferences.getInstance();
    DateTime timestamp = new DateTime.now();
    print("[BackgroundFetch] Event received: $taskId ${timestamp.toIso8601String()}");

    switch (taskId){
      case "flutter_background_fetch":
        if(_prefs.getBool(SMART_NOTIFICATION_KEY)){
          _prepareForSmartNotification();
        }
        break;
      case "com.inthenou.app.reccomendation":
//        if(_prefs.getBool(SMART_NOTIFICATION_KEY)){
//          _prepareForNotification();
//        }
        _doRecommendation();
        break;
      case "com.inthenou.app.cleanup":
        NotificationHandler.cleanupNotifications();
        break;
    }

    // Signal to finish the background task
    BackgroundFetch.finish(taskId);
  }

  /// Preparation for creating the Smart notifications by getting the ones
  /// already scheduled and a lis of [Event] that the user is following.
  ///
  /// Delegates actually creating the Notifications to [_doSmartNotification]
  /// by passing the list of scheduled  notifications in the form of
  /// [NotificationObject] and json.
  /// Upon receiving the json list back it removes any that have already
  /// been delivered to the user.
  static void _prepareForSmartNotification() async{

    Geolocator().checkGeolocationPermissionStatus().then((value) {
      if(value == GeolocationStatus.denied ||
          value == GeolocationStatus.unknown){
        NotificationHandler.showAlertNotification(NotificationObject(
          id: ALERT_NOTIFICATION_ID,
          payload: "",
          time: DateTime.now(),
          type: NotificationType.Alert
        ), "Location Permission", "Location permission is disabled",
            "We tried scheduling a Smart Notification but the Location "
                "permissions are denied. Please provide the permission or "
                "turn off the feature.");
      }
      return;
    });
    UserRepo _userRepo = UserRepo();
    _prefs = await SharedPreferences.getInstance();

    // Gets all Smart Notifications that are scheduled already
    List<String> jsonNotifications = _prefs.getStringList
      (SMART_NOTIFICATION_LIST) ?? new List();

    // Calls the database to get all the events followed by the uer
    List<Event> _events = await _userRepo.getAllFollowedEvents();

    // Decodes the json strings into a map with the NotificationObject fields
    // Also removes the followed events that have been scheduled already
    Map notificationMap;
    jsonNotifications.forEach((notification) {
      notificationMap = jsonDecode(notification);
      // The id of the notification is the same as the eventUID for a given
      // Smart Notification
      _events.removeWhere((event) => event.UID == notificationMap["id"]);
    });

    jsonNotifications = await NotificationHandler.doSmartNotification(
        _events,
        jsonNotifications);

    _prefs.setStringList(SMART_NOTIFICATION_LIST,jsonNotifications);
  }


  static void _doRecommendation() async{
    EventsRepo _eventRepo = new EventsRepo();
    UserRepo _userRepo = new UserRepo();
    _prefs = await SharedPreferences.getInstance();

    String lastDate = _prefs.getString(LAST_RECOMMENDATION_DATE_KEY);

    List<Event> newEvents = await _eventRepo.getNewEvents(lastDate);
    List<Tag> userTags = await _userRepo.getUserTags();
    List<Event> recommendedEvents = new List();

    List<Tag> commonTags;
    // Remove all events that have been ran through the recommendation
    newEvents.removeWhere((event) => event.recommended != null);
    newEvents.forEach((event) {
      commonTags = _checkTagsSimilarity(event.tags, userTags);

      double weight = 0;
      if(commonTags.length >= 2){
        weight = calcWeightedSum(commonTags, event.tags.length);
        if(weight >= WEIGHTED_SUM_THRESHOLD){
          event.recommended = true;
          recommendedEvents.add(event);
        }
        else {
          event.recommended = false;
        }
      } else{
        event.recommended = false;
      }
    });

    if(recommendedEvents.length > 0){
      _eventRepo.requestRecommendation(recommendedEvents);

      NotificationHandler.scheduleRecommendationNotification
        (NotificationObject(id: 0,
          type: NotificationType.RecommendationNotification,
          time: DateTime.now(),
          payload: ""),"Event Recommendations!",
          "You have ${recommendedEvents.length} new Events",
          "There are ${recommendedEvents.length} new Events recommended to you "
              "based on your interests. Check em out!");
    }

    _prefs.setString(LAST_RECOMMENDATION_DATE_KEY,
        Utils.formatTimeStamp(DateTime.now()));
  }

  static List<Tag> _checkTagsSimilarity(List<Tag> eventTags, List<Tag> userTags){
    List<Tag> commonTags = new List();
    userTags.forEach((tag) {
      if(eventTags.any((element) => element.name == tag.name)){
        commonTags.add(tag);
      }
    });
    return commonTags;
  }

  static double calcWeightedSum(List<Tag> commonTags, int eventTagsNumber){
    double relevanceValue = RELEVANCE_VALUE_FACTOR/eventTagsNumber;
    double sum = 0;
    commonTags.forEach((tag) {
      sum += (tag.weight/100)*relevanceValue;
    });
    return sum;
  }

  static void onClickEnable(enabled) {
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

}

