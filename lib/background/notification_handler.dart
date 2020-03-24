import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

class NotificationHandler {

  static void scheduleSmartNotification(String title, String description,
    String bigDescription, DateTime scheduledDate, String payload) async {
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
        DateTime.now().millisecond, title, description,
        scheduledDate,
        platformChannelSpecifics, payload: payload);

  }

}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}