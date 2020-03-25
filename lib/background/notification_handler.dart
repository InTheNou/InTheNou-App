import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

class NotificationHandler {

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
        'com.inthenou.app.channel.test',
        'Test',
        'This is a test channel',
        importance: Importance.High,
        style: AndroidNotificationStyle.BigText,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, null);

    await flutterLocalNotificationsPlugin.schedule(
        id, title, description, scheduledDate,
        platformChannelSpecifics, payload: payload);

  }

}

class SmartNotification {
  final int id;
  final int eventUID;

  SmartNotification({
    @required this.id,
    @required this.eventUID,
  });

  SmartNotification.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        eventUID = json['eventUID'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'eventUID': eventUID,
      };
}