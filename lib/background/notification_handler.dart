import 'dart:convert';
import 'dart:math';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

class NotificationHandler {

  static SharedPreferences _prefs;
  static final Geolocator _geolocator = Geolocator();

  /// Checks if a Smart Notification needs to be created, and creates a
  /// Default notification
  ///
  /// This is called through the [EventFeedStore] whenever the user follows an
  /// event
  static void checkNotifications(Event event) async{
    _prefs = await SharedPreferences.getInstance();

    // Gets all Smart Notifications that are scheduled already
    List<String> jsonNotifications = _prefs.getStringList
      (SMART_NOTIFICATION_LIST) ?? new List();

    // Check if the event needs a notification and if so, add to the list
    jsonNotifications = await NotificationHandler.doSmartNotification(
        [event], jsonNotifications);

    // Update notification list
    _prefs.setStringList(SMART_NOTIFICATION_LIST,jsonNotifications);

    // Create Default notification
    makeDefaultNotification(event);
  }

  /// Cancels Smart and Default notifications associated with this event
  static void cancelNotification(Event event) async{
    _prefs = await SharedPreferences.getInstance();
    List<String> jsonSmart = _prefs.getStringList
      (SMART_NOTIFICATION_LIST) ?? new List();
    List<String> jsonDefault = _prefs.getStringList
      (DEFAULT_NOTIFICATION_LIST) ?? new List();

    // Look for the Smart and Default notification that is for this event and
    // cancel it using the ID
    int smartIndex = jsonSmart.indexWhere((element) {
      return NotificationObject.fromJson(jsonDecode(element)).payload
          == event.UID.toString();
    });
    if(smartIndex != -1){
      flutterLocalNotificationsPlugin
          .cancel(jsonDecode(jsonSmart[smartIndex])["id"]);
      jsonSmart.removeAt(smartIndex);
    }

    int defaultIndex = jsonDefault.indexWhere((element) {
      return NotificationObject.fromJson(jsonDecode(element)).payload
          == event.UID.toString();
    });
    if(defaultIndex != -1){
      flutterLocalNotificationsPlugin
          .cancel(jsonDecode(jsonDefault[defaultIndex])["id"]);
      jsonDefault.removeAt(defaultIndex);
    }

    var pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var pendingNotificationRequest in pendingNotificationRequests) {
      debugPrint(
          'pending notification: [id: ${pendingNotificationRequest.id}, title: ${pendingNotificationRequest.title}]');
    }
  }

  /// This method goes through all the current scheduled Smart Notifications
  /// and cancels them.
  ///
  /// Used when the user disables the functionality in the settings
  static void cancelAllSmartNotifications() async{
    _prefs = await SharedPreferences.getInstance();
    List<String> jsonSmart = _prefs.getStringList
      (SMART_NOTIFICATION_LIST) ?? new List();

    Map notificationMap;
    jsonSmart.forEach((notification) {
      notificationMap = jsonDecode(notification);
      flutterLocalNotificationsPlugin.cancel(notificationMap["id"]);
    });
  }

  /// Verifies if an event needs to be have a notification scheduled and does
  /// so if determined.
  ///
  /// Iterates trough the [events] to check which are happening during the
  /// next 24 hours. Then using the user's location received using
  /// [Geolocator], the distance and time to walk to the event are calculated
  /// using [greatCircleDistanceCalc] and [timeToTravel]. Then it is
  /// determined if the scheduled can be deferred to the next time the Smart
  /// Notification tasks is initiated (in 15 minutes). In the case that it
  /// would be toot late to notify the user, then the Notification is
  /// scheduled using[NotificationHandler.scheduleSmartNotification]
  static Future<List<String>> doSmartNotification(List<Event> events,
      List<String> jsonNotifications) async{

    Coordinate userCoords;
    _geolocator.forceAndroidLocationManager = true;
    await _geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy
        .high).then((coordinate) {
      userCoords = Coordinate(coordinate.latitude, coordinate.longitude);
    });

    DateTime timestamp = new DateTime.now();
    Duration timeToEvent;
    int notificationID;
    events.forEach((event) {
      timeToEvent = event.startDateTime.difference(timestamp);
      if (timeToEvent.inHours < 24 && !timeToEvent.isNegative){
        double distance = greatCircleDistanceCalc(userCoords, event.room.coordinates);
        double timeToWalk = timeToTravel(distance);
        int seconds = ((timeToWalk - timeToWalk.floor()) * 60).ceil();

//        print("user: $userCoords");
//        print("event: ${event.room.coordinates}");
//        print("[SmartNotification] Starts in: ${timeToEvent.toString()}");
//        print("[SmartNotification] Starts at: ${event.startDateTime.toString()}");
//        print("[SmartNotification] We calculated: $distance $timeToWalk");
//        print(buildGoogleMapsLink2(userCoords, event.room.coordinates));

        DateTime scheduleTime;
        NotificationObject eventNotification;
        if(timeToEvent.inMinutes - 15 < timeToWalk){
          scheduleTime = event.startDateTime.subtract(Duration(minutes:
          timeToWalk.ceil(), seconds: seconds));
//          print("[SmartNotification] Scheduled for at: "
//              "${scheduleTime.toString()}");
          notificationID = _prefs.getInt(NOTIFICATION_ID_KEY);
          _prefs.setInt(NOTIFICATION_ID_KEY, notificationID+1);
          // Save the Notification to mark it as scheduled
          eventNotification = NotificationObject(
              type: NotificationType.SmartNotification,
              id: notificationID, time: scheduleTime, payload: event.UID.toString());
          jsonNotifications.add(jsonEncode(eventNotification));

          NumberFormat nf = NumberFormat("#####.##", "en_US");
          NumberFormat nf2 = NumberFormat("#####", "en_US");
          DateFormat df = new DateFormat("K:mm a");
          String startOfEvent = "The event starts at ${df.format(event.startDateTime)}";
          NotificationHandler.scheduleSmartNotification(
              notificationID,
              event.title,
              startOfEvent,
              startOfEvent + "\n" + "You are ${nf.format(distance)} miles away from the "
                  "event, it will take you ${nf2.format(timeToWalk)} mins to "
                  "walk to the event.",
              scheduleTime,
              jsonEncode(eventNotification)
          );
        }
      }
    });
    return jsonNotifications;
  }

  /// Setup of the notification and schedules it
  static void scheduleSmartNotification(int id, String title,
      String description, String bigDescription, DateTime scheduledDate,
      String payload) async {
    var bigTextStyleInformation = BigTextStyleInformation(
        bigDescription,
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        summaryText: '<b>Smart Notification</b>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.inthenou.app.channel.smartnotification',
        'Smart Notification',
        'Smart notifications for Events followed',
        importance: Importance.Max,
        priority: Priority.High,
        visibility: NotificationVisibility.Public,
        style: AndroidNotificationStyle.BigText,
        groupKey: DEFAULT_NOTIFICATION_KEY,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.schedule(
        id, title, description, scheduledDate,
        platformChannelSpecifics, payload: payload);

  }

  /// Creates the Default notification for the [event]
  ///
  /// Calculates the time to send the notification based on the user setting
  static void makeDefaultNotification(Event event) async{
    _prefs = await SharedPreferences.getInstance();
    int defaultTime = _prefs.getInt(DEFAULT_NOTIFICATION_KEY);
    int notificationID = _prefs.getInt(NOTIFICATION_ID_KEY);
    _prefs.setInt(NOTIFICATION_ID_KEY, notificationID+1);

    // Gets all Default Notifications that are scheduled already
    List<String> jsonNotifications = _prefs.getStringList
      (DEFAULT_NOTIFICATION_LIST) ?? new List();

    DateTime notificationTime = event.startDateTime
        .subtract(Duration(minutes: defaultTime));
    NotificationObject notification = NotificationObject(
        type: NotificationType.DefaultNotification,
        id: notificationID, time: notificationTime,
        payload: event.UID.toString());

    DateFormat df = new DateFormat("K:mm a");
    String startOfEvent = "The event starts at ${df.format(event.startDateTime)}";
    scheduleDefaultNotification(notification,
      event.title, startOfEvent
    );

    // Update notification list and NotificationID
    jsonNotifications.add(jsonEncode(notification));
    _prefs.setStringList(DEFAULT_NOTIFICATION_LIST,jsonNotifications);
  }

  /// Setup of the notification and schedules it
  static void scheduleDefaultNotification(NotificationObject notification,
      String title, String description) async {
    var defaultStyleInformation = DefaultStyleInformation(true, true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.inthenou.app.channel.defaultnotification',
        'Default Event Notification',
        'Default notifications for Events followed.',
        importance: Importance.Max,
        priority: Priority.High,
        visibility: NotificationVisibility.Public,
        style: AndroidNotificationStyle.Default,
        groupKey: SMART_NOTIFICATION_KEY,
        styleInformation: defaultStyleInformation);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.schedule(
        notification.id, title, description, notification.time,
        platformChannelSpecifics, payload: jsonEncode(notification));
  }

  // Helper Methods

  static String _getTimeToEvent(DateTime eventTime, DateTime notificationTIme){
    Duration time = eventTime.difference(notificationTIme);
    if(time.inHours > 1){
      return "Event starts in ${time.inHours} hrs and "
          "${time.inMinutes-(time.inHours*60)} min";
    } else{
      return "Event starts in ${time.inMinutes} mins";
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


class NotificationObject {
  final NotificationType type;
  final int id;
  final DateTime time;
  final String payload;

  NotificationObject({
    @required this.type,
    @required this.id,
    @required this.time,
    @required this.payload,
  });

  NotificationObject.fromJson(Map<String, dynamic> json)
      : type = notificationTypeFromString(json['type']),
        id = json['id'],
        time = DateTime.parse(json["time"]),
        payload = json['payload'];

  Map<String, dynamic> toJson() =>
      {
        'type': notificationTypeString(type),
        'id': id,
        'time': time.toIso8601String(),
        'payload': payload,
      };
}