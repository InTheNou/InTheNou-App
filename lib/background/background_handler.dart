import 'dart:convert';
import 'dart:async';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/repos/user_repo.dart';
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
  static Future<void> initPlatformState() async {
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
        delay: 5*60000,
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
          _prepareForNotification();
        }
        break;
      case "com.inthenou.app.reccomendation":
//        if(_prefs.getBool(SMART_NOTIFICATION_KEY)){
//          _prepareForNotification();
//        }
        _doRecommendation();
        break;
      case "com.inthenou.app.cleanup":
        cleanupNotifications();
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
  static void _prepareForNotification() async{
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


  static void _doRecommendation(){
//    NotificationHandler.scheduleSmartNotification("Reccomendation", "Reccomen"
//        "dation description", DateTime.now(), "");
  }

  static List<Tag> _checkTagsSimilarity(List<Tag> eventTags,
      List<Tag> userTags){
    List<Tag> commonTags = new List();
    userTags.forEach((tag) {
      if(eventTags.contains(tag)){
        commonTags.add(tag);
      }
    });
    return commonTags;
  }

  /// Cleans up old notifications that have been delivered
  static void cleanupNotifications() async{
    _prefs = await SharedPreferences.getInstance();

    // Gets all Notifications that are scheduled already
    List<String> jsonSmart = _prefs.getStringList
      (SMART_NOTIFICATION_LIST) ?? new List();
    List<String> jsonDefault = _prefs.getStringList
      (DEFAULT_NOTIFICATION_LIST) ?? new List();

    // Remove all notifications that have been delivered
    DateTime now = DateTime.now();
    jsonSmart.removeWhere((json)
      => NotificationObject.fromJson(jsonDecode(json)).time.difference(now).isNegative
    );
    jsonDefault.removeWhere((json)
      => NotificationObject.fromJson(jsonDecode(json)).time.difference(now).isNegative
    );
    _prefs.setStringList(SMART_NOTIFICATION_LIST,jsonSmart);
    _prefs.setStringList(DEFAULT_NOTIFICATION_LIST,jsonDefault);
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

