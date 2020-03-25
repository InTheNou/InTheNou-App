import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/repos/user_repo.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:InTheNou/models/coordinate.dart';

class BackgroundHandler {

  static SharedPreferences _prefs;
  ///
  /// Configure the BackgroundFetch library. It creates a background process
  /// that is initialized every [minimumFetchInterval] and calls the function
  /// [onBackgroundFetch]. The SmartNotification functionality gets handled
  /// every time this initiated and it it handled in [_doSmartNotification].
  /// In this method we can also schedule any other background tasks that we
  /// wish to run, be it one-hot or recurring. Here we initialize the
  /// Recommendation feature handled by [_doSmartNotification]
  ///
  /// The variable [stopOnTerminate] makes these tasks to operate when the
  /// app is not active. [enableHeadless] makes it so that a headless
  /// background task
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

    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');

    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.inthenou.app.reccomendation",
        delay: 60000,
        periodic: true,
        forceAlarmManager: true,
        stopOnTerminate: false,
        enableHeadless: true
    )).then((value) {
      print('[reccomendation] status: $value');
    });
  }

  static final Geolocator _geolocator = Geolocator();
  // This is the fetch-event callback.
  static void onBackgroundFetch(String taskId) async {
    _prefs = await SharedPreferences.getInstance();
    DateTime timestamp = new DateTime.now();
    print("[BackgroundFetch] Event received: $taskId ${timestamp.toIso8601String()}");

    switch (taskId){
      case "flutter_background_fetch":
        if(_prefs.getBool(SMART_NOTIFICATION_KEY)){
          _doSmartNotification();
        }
        break;
      case "com.inthenou.app.reccomendation":
        if(_prefs.getBool(SMART_NOTIFICATION_KEY)){
          _doSmartNotification();
        }
        _doRecommendation();
        break;
    }

    // Signal to finish the background task
    BackgroundFetch.finish(taskId);
  }

  static void _doSmartNotification() async{
    UserRepo _userRepo = UserRepo();
    _prefs = await SharedPreferences.getInstance();

    // Get all Smart Notifications that are scheduled already
    List<String> json = _prefs.getStringList(SMART_NOTIFICATION_LIST) ?? new List();
    List<SmartNotification> smartNotifications = new List();

    Map smartMap;
    json.forEach((element) {
      smartMap = jsonDecode(element);
      smartNotifications.add(SmartNotification.fromJson(smartMap));
    });
    List<Event> _events = await _userRepo.getAllFollowedEvents();

    Coordinate userCoords;
    _geolocator.forceAndroidLocationManager = true;
    await _geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy
        .high).then((value) {
      userCoords = Coordinate(value.latitude, value.longitude);
      }
    );

    DateTime timestamp = new DateTime.now();
    Duration timeToEvent;

    smartNotifications.forEach((notif) {
      print(jsonEncode(notif));
      _events.removeWhere((event) => event.UID == notif.eventUID);
    });

    _events.forEach((event) {
      timeToEvent = event.startDateTime.difference(timestamp);
      if (timeToEvent.inHours < 24 && !timeToEvent.isNegative){
        print("user: $userCoords");
        print("event: ${event.room.coordinates}");
        double distance = greatCircleDistanceCalc(userCoords, event.room.coordinates);
        double timeToWalk = timeToTravel(distance);
        print("[SmartNotification] Starts in calculated: ${timeToEvent.toString()}");
        print("[SmartNotification] We calculated: $distance $timeToWalk");
        print(buildGoogleMapsLink2(userCoords, event.room.coordinates));

        if(timeToEvent.inMinutes - 15 < timeToWalk){
          smartNotifications.add(SmartNotification(
              id: event.UID,
              eventUID: event.UID));
          json.add(jsonEncode(smartNotifications[smartNotifications.length-1]));

          NumberFormat nf = NumberFormat("#####.##", "en_US");
          NumberFormat nf2 = NumberFormat("#####", "en_US");
          String timeToEvent = _getTimeToEvent(event.startDateTime,
              event.startDateTime.subtract(Duration(minutes:timeToWalk.ceil())));
          NotificationHandler.scheduleSmartNotification(
              event.UID,
              event.title,
              timeToEvent,
              timeToEvent + "\n" + "You are ${nf.format(distance)} miles away from the "
                  "event, it will take you ${nf2.format(timeToWalk)} mins to "
                  "walk to the event.",
              event.startDateTime.subtract(Duration(minutes: timeToWalk.ceil())),
              event.UID.toString()
          );
        }
      }
    });

    _prefs.setStringList(SMART_NOTIFICATION_LIST,json);
  }

  static String _getTimeToEvent(DateTime eventTime, DateTime notificationTIme){
    Duration time = eventTime.difference(notificationTIme);
    if(time.inHours > 1){
      return "Event starts in ${time.inHours} hrs and "
          "${time.inMinutes-(time.inHours*60)} min";
    } else{
      return "Event starts in ${time.inMinutes} mins";
    }
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

  ///
  /// Calculation of the Great Circle Distance between two GPS coordinates.
  /// This method uses the Haversine formula and takes into account the
  /// curvature of the earth into the measurement, this makes it very
  /// accurate in small distances, as opposed to using plain trigonometry or
  /// other methods that take the Earth as a flat plane.
  /// For a great explanation please visit this site:
  /// http://mathforum.org/library/drmath/view/51879.html
  ///
  /// The result is multiplied by 1.3 to account for the Euclidian distance
  /// calculation being different than if we take into account the walking
  /// maths.
  /// https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3835347/
  static double greatCircleDistanceCalc(Coordinate userCoords,
      Coordinate eventCoords){
    int earthRad = 3959;
    double uLat = toRadians(userCoords.lat);
    double eLat = toRadians(eventCoords.lat);
    double deltaLat = toRadians(eventCoords.lat - userCoords.lat);
    double deltaLong = toRadians(eventCoords.long - userCoords.long);

    double a = (sin(deltaLat/2) * sin(deltaLat/2)) +
        sin(deltaLong/2) * sin(deltaLong/2) * cos(uLat) * cos(eLat);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double distance = earthRad * c;
    return distance*1.3;
  }

  ///
  /// Here we divide the distance by the average walking speed of 3mph. Then
  /// we multiply by 60 minutes to get the time it would take to walk to the
  /// event in minutes.
  ///
  ///  [distance] (mi)                      60 min
  /// ---------------------------------- * ------- = timeToWalk (min)
  /// [AVERAGE_WALKING_SPEED] (mph)          1 hr
  ///
  static double timeToTravel(double distance){
    return (distance/AVERAGE_WALKING_SPEED)*60;
  }

  static double toRadians(double val){
    return val*pi/180;
  }

}

