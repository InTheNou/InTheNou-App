import 'dart:convert' as convert;
import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:InTheNou/stores/event_feed_store.dart';
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
  static DialogService _dialogService = DialogService();
  static EventsRepo eventsRepo = EventsRepo();

  /// Checks if a Smart Notification needs to be created, and creates a
  /// Default notification
  ///
  /// This is called through the [EventFeedStore] whenever the user follows an
  /// [event]
  static void checkNotifications(Event event) async{
    _prefs = await SharedPreferences.getInstance();

    try{
      // Gets all Smart Notifications that are scheduled already
      List<String> jsonNotifications = _prefs.getStringList
        (SMART_NOTIFICATION_LIST) ?? new List();
      // Check if the event needs a notification and if so, add to the list
      event = await eventsRepo.getEvent(event.UID);
      if(_prefs.getBool(SMART_NOTIFICATION_KEY) &&
          event.startDateTime.isAfter(DateTime.now())){
        if(_prefs.getBool(DEBUG_NOTIFICATION_KEY)){
          showDebugNotification(NotificationObject(
              id: SMART_ALERT_NOTIFICATION_ID,
              payload: "",
              time: DateTime.now(),
              type: NotificationType.Debug
          ), "Smart Notification", "Trying to Create Smart Notification",
              "Trying to Create Smart Notification");
        }

        jsonNotifications = await NotificationHandler.doSmartNotification(
            [event], jsonNotifications);

        // Update notification list
        _prefs.setStringList(SMART_NOTIFICATION_LIST,jsonNotifications);
      }
    } catch(e){
      _dialogService.showDialog(type: DialogType.Error, title: "Error",
          description: e.toString());
      showAlertNotification(NotificationObject(
          id: SMART_ALERT_NOTIFICATION_ID,
          payload: "",
          time: DateTime.now(),
          type: NotificationType.Alert
      ), "Smart Notification Error", "Unable to Schedule Smart Notification",
          "There was an error trying to schedule a Smart notification, we "
              "will try again shortly");
    }

    // Get all the details for event and create Default notification
    _makeDefaultNotification(event);
  }

  /// Cancels Smart and Default notifications associated with this [event]
  static void cancelNotification(Event event) async{
    _prefs = await SharedPreferences.getInstance();
    List<String> jsonSmart = _prefs.getStringList
      (SMART_NOTIFICATION_LIST) ?? new List();
    List<String> jsonDefault = _prefs.getStringList
      (DEFAULT_NOTIFICATION_LIST) ?? new List();

    // Look for the Smart and Default notification that is for this event and
    // cancel it using the ID
    NotificationObject notif;
    jsonSmart.removeWhere((element) {
      notif = NotificationObject.fromJson(convert.jsonDecode(element));
      if(notif.payload == event.UID.toString()){
        flutterLocalNotificationsPlugin
            .cancel(notif.id);
      }
      return notif.payload == event.UID.toString();
    });

    jsonDefault.removeWhere((element) {
      notif = NotificationObject.fromJson(convert.jsonDecode(element));
      if(notif.payload == event.UID.toString()){
        flutterLocalNotificationsPlugin
            .cancel(notif.id);
      }
      return notif.payload == event.UID.toString();
    });

    // Update the list of notifications
    _prefs.setStringList(SMART_NOTIFICATION_LIST, jsonSmart);
    _prefs.setStringList(DEFAULT_NOTIFICATION_LIST, jsonDefault);

    print("Smart Notifications: ");
    print(jsonSmart);
    print("Default Notifications: ");
    print(jsonDefault);
    var pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var pendingNotificationRequest in pendingNotificationRequests) {
      debugPrint(
          'Pending notification: [id: ${pendingNotificationRequest.id}, '
              'title: ${pendingNotificationRequest.title}]');
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
      notificationMap = convert.jsonDecode(notification);
      flutterLocalNotificationsPlugin.cancel(notificationMap["id"]);
    });
    _prefs.setStringList(SMART_NOTIFICATION_LIST, null);
  }

  /// Utility method to clear out all notifications for Smart and Default
  static void cancelAllNotifications() async{
    _prefs = await SharedPreferences.getInstance();
    flutterLocalNotificationsPlugin.cancelAll();
    _prefs.setStringList(SMART_NOTIFICATION_LIST, null);
    _prefs.setStringList(DEFAULT_NOTIFICATION_LIST, null);
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
    jsonSmart.removeWhere((json) => NotificationObject.fromJson(
        convert.jsonDecode(json)).time.difference(now).isNegative
    );
    jsonDefault.removeWhere((json) => NotificationObject.fromJson(
        convert.jsonDecode(json)).time.difference(now).isNegative
    );
    _prefs.setStringList(SMART_NOTIFICATION_LIST,jsonSmart);
    _prefs.setStringList(DEFAULT_NOTIFICATION_LIST,jsonDefault);
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
  /// scheduled using[NotificationHandler._scheduleSmartNotification]
  static Future<List<String>> doSmartNotification(List<Event> events,
      List<String> jsonNotifications) async{
    _prefs = await SharedPreferences.getInstance();
    Coordinate userCoords;
    try{
//      _geolocator.forceAndroidLocationManager = true;
      await _geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy
          .high).then((coordinate) {
        userCoords = Coordinate(coordinate.latitude, coordinate.longitude, 0);
      });

      DateTime timestamp = new DateTime.now();
      Duration timeToEvent;
      int notificationID;
      events.forEach((event) {
        timeToEvent = event.startDateTime.difference(timestamp);
        if(event.status =="active" &&
            Utils.isEventInTheNextDay(event.startDateTime, timestamp)){
          double timeToWalk = Utils.GPSTimeToWalkCalculation(timeToEvent,
              userCoords, event.room.coordinates);
          if(Utils.isScheduleSmartNecessary(timeToEvent, timeToWalk)){
            int seconds = ((timeToWalk - timeToWalk.floor()) * 60).ceil();

            DateTime scheduleTime;
            NotificationObject eventNotification;

            scheduleTime = event.startDateTime.subtract(Duration(minutes:
            timeToWalk.ceil(), seconds: seconds));
            print("[SmartNotification] Scheduled for at: "
                "${scheduleTime.toString()}");
            notificationID = _prefs.getInt(NOTIFICATION_ID_KEY);
            _prefs.setInt(NOTIFICATION_ID_KEY, notificationID+1);
            // Save the Notification to mark it as scheduled
            eventNotification = NotificationObject(
                type: NotificationType.SmartNotification,
                id: notificationID, time: scheduleTime, payload: event.UID.toString());
            jsonNotifications.add(convert.jsonEncode(eventNotification));

            NumberFormat nf = NumberFormat("#####.##", "en_US");
            DateFormat df = new DateFormat("K:mm a");
            String startOfEvent = "The event starts at ${df.format(event.startDateTime)}";
            NotificationHandler._scheduleSmartNotification(
                notificationID,
                event.title,
                startOfEvent,
                startOfEvent + "\n" + "You are"
                    " ${nf.format(Utils.distanceToTravel(timeToWalk))} miles "
                    "away from the "
                    "event, it will take you ${Utils.toSmartTime(timeToWalk)} to "
                    "walk to the event.",
                scheduleTime,
                convert.jsonEncode(eventNotification)
            );
            if(_prefs.getBool(DEBUG_NOTIFICATION_KEY)){
              showDebugNotification(NotificationObject(
                  id: SMART_ALERT_NOTIFICATION_ID,
                  payload: "",
                  time: DateTime.now(),
                  type: NotificationType.Debug
              ), "Smart Notification", "Scheduled",
                  event.title+ " "+scheduleTime.toIso8601String());
            }
          }
        }
      });
    } catch(e){
      showAlertNotification(NotificationObject(
          id: SMART_ALERT_NOTIFICATION_ID,
          payload: "",
          time: DateTime.now(),
          type: NotificationType.Alert
      ), "Smart Notification Error", "Unable to Schedule Smart Notification",
          e.toString());
    }

    return jsonNotifications;
  }

  /// Creates the Default notification for the [event]
  ///
  /// Calculates the time to send the notification based on the user setting
  static void _makeDefaultNotification(Event event) async{
    if(Utils.isScheduleDefaultNecessary(event.startDateTime, DateTime.now())){
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
      _scheduleDefaultNotification(notification,
          event.title, startOfEvent
      );

      // Update notification list and NotificationID
      jsonNotifications.add(convert.jsonEncode(notification));
      _prefs.setStringList(DEFAULT_NOTIFICATION_LIST,jsonNotifications);
    }
  }

  /// Setup of the Smart notification and schedules it
  static void _scheduleSmartNotification(int id, String title,
      String description, String bigDescription, DateTime scheduledDate,
      String notifPayload) async {
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
        color: primaryColor[50],
        ledColor: primaryColor[50],
        enableLights: true,
        ledOnMs: 100,
        ledOffMs: 100,
        visibility: NotificationVisibility.Public,
//        groupKey: SMART_NOTIFICATION_GID,
        icon: "ic_notification",
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.schedule(
        id, title, description, scheduledDate,
        platformChannelSpecifics, payload: notifPayload);
  }

  /// Setup of the Default notification and schedules it
  static void _scheduleDefaultNotification(NotificationObject notification,
      String title, String description) async {
    var defaultStyleInformation = DefaultStyleInformation(true, true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.inthenou.app.channel.defaultnotification',
        'Default Event Notification',
        'Default notifications for Events followed.',
        importance: Importance.Max,
        priority: Priority.High,
        icon: "ic_notification",
        color: primaryColor[50],
        ledColor: primaryColor[50],
        enableLights: true,
        ledOnMs: 100,
        ledOffMs: 100,
        visibility: NotificationVisibility.Public,
//        groupKey: DEFAULT_NOTIFICATION_GID,
        styleInformation: defaultStyleInformation);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.schedule(
        notification.id, title, description, notification.time,
        platformChannelSpecifics, payload: convert.jsonEncode(notification));
  }

  /// Setup of the Recommendation notification and schedules it
  static void scheduleRecommendationNotification(
      NotificationObject notification, String title, String description,
      String bigDescription) async {
    var bigTextStyleInformation = BigTextStyleInformation(
        bigDescription,
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        summaryText: '<b>Recommendation</b>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.inthenou.app.channel.reccomendation',
        'Recommendation Notification',
        'Notifications of Events that have been recommended based on interest.',
        importance: Importance.Max,
        priority: Priority.High,
        icon: "ic_notification",
        color: primaryColor[50],
        ledColor: primaryColor[50],
        enableLights: true,
        ledOnMs: 100,
        ledOffMs: 100,
        visibility: NotificationVisibility.Public,
//        groupKey: RECOMMENDATION_NOTIFICATION_GID,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.show(
        notification.id, title, description,
        platformChannelSpecifics,
        payload: convert.jsonEncode(notification));
  }

  /// Setup of the Alert notification and schedules it
  static void showAlertNotification(
      NotificationObject notification, String title, String description,
      String bigDescription) async {
    var bigTextStyleInformation = BigTextStyleInformation(
        bigDescription,
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        summaryText: '<b>Alert</b>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.inthenou.app.channel.alert',
        'Alert Notification',
        'Notifications of Alerts or Errors.',
        importance: Importance.Low,
        priority: Priority.Low,
        icon: "ic_notification",
        color: primaryColor[50],
        ledColor: primaryColor[50],
        enableLights: true,
        ledOnMs: 100,
        ledOffMs: 100,
        visibility: NotificationVisibility.Public,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.show(
        notification.id, title, description,
        platformChannelSpecifics,
        payload: convert.jsonEncode(notification));
  }

  /// Setup of the Cancellation notification and schedules it
  static void showCancellationNotification(
      NotificationObject notification, String title, String description,
      String bigDescription) async {
    var bigTextStyleInformation = BigTextStyleInformation(
        bigDescription,
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        summaryText: '<b>Cancellations</b>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.inthenou.app.channel.cancellations',
        'Cancellations Notification',
        'Notifications of Cancelled Events.',
        importance: Importance.Max,
        priority: Priority.High,
        icon: "ic_notification",
        color: primaryColor[50],
        ledColor: primaryColor[50],
        enableLights: true,
        ledOnMs: 100,
        ledOffMs: 100,
        visibility: NotificationVisibility.Public,
        groupKey: CANCELLATION_NOTIFICATION_GID,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.show(
        notification.id, title, description,
        platformChannelSpecifics,
        payload: convert.jsonEncode(notification));
  }

  /// Setup of the Debug notification and schedules it
  static void showDebugNotification(
      NotificationObject notification, String title, String description,
      String bigDescription) async {
    var bigTextStyleInformation = BigTextStyleInformation(
        bigDescription,
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        summaryText: '<b>Debug</b>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.inthenou.app.channel.debug',
        'Debug Notification',
        'Notifications of Debug Alerts or Errors.',
        importance: Importance.Low,
        priority: Priority.Low,
        playSound: false,
        color: primaryColor[50],
        ledColor: primaryColor[50],
        enableLights: true,
        ledOnMs: 100,
        ledOffMs: 100,
        icon: "ic_notification",
        visibility: NotificationVisibility.Public,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.show(
        notification.id, title, description,
        platformChannelSpecifics,
        payload: convert.jsonEncode(notification));
  }

}


/// Object for Notifications created in the app.
///
/// Utility model that is sent with the notification so that they can be
/// identified when they are received.
///
/// {@category Model}
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
      : type = Utils.notificationTypeFromString(json['type']),
        id = json['id'],
        time = DateTime.parse(json["time"]),
        payload = json['payload'];

  Map<String, dynamic> toJson() =>
      {
        'type': Utils.notificationTypeString(type),
        'id': id,
        'time': time.toIso8601String(),
        'payload': payload,
      };
}