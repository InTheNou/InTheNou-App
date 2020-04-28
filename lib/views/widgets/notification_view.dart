import 'package:InTheNou/assets/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationView extends StatelessWidget {

  NotificationView();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Notifications'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new OutlineButton(
              child: new Text('Default'),
              onPressed: () async {
                var defaultStyleInformation = DefaultStyleInformation(true, true);

                var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                    'com.inthenou.app.channel.alert',
                    'Alert Notification',
                    'Notifications of Alerts or Errors.',
                    importance: Importance.Max,
                    priority: Priority.High,
                    visibility: NotificationVisibility.Public,
                    styleInformation: defaultStyleInformation);
                var platformChannelSpecifics = NotificationDetails(
                    androidPlatformChannelSpecifics, null);

                await flutterLocalNotificationsPlugin.show(
                    4, "Default", "Default Notification",
                    platformChannelSpecifics,
                    payload: "");
              },
            ),
            new OutlineButton(
              child: new Text('Big'),
              onPressed: () async {
                var bigTextStyleInformation = BigTextStyleInformation(
                    "big Text",
                    htmlFormatBigText: true,
                    contentTitle: '<b>Big Text</b>',
                    htmlFormatContentTitle: true,
                    summaryText: '<b>Big</b>',
                    htmlFormatSummaryText: true);
                var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                    'com.inthenou.app.channel.cancellations',
                    'Cancellations Notification',
                    'Notifications of Cancelled Events.',
                    importance: Importance.Max,
                    priority: Priority.High,
                    visibility: NotificationVisibility.Public,
                    groupKey: "test",
                    setAsGroupSummary: true,
                    styleInformation: bigTextStyleInformation);
                var platformChannelSpecifics = NotificationDetails(
                    androidPlatformChannelSpecifics, null);

                await flutterLocalNotificationsPlugin.show(
                    50, "Big Text", "Test 1",
                    platformChannelSpecifics,
                    payload: "");
                await flutterLocalNotificationsPlugin.show(
                    51, "Big Text", "Test 2",
                    platformChannelSpecifics,
                    payload: "");
                await flutterLocalNotificationsPlugin.show(
                    52, "Big Text", "Test 3",
                    platformChannelSpecifics,
                    payload: "");
                await flutterLocalNotificationsPlugin.show(
                    53, "Big Text", "Test 4",
                    platformChannelSpecifics,
                    payload: "");
              },
            ),
            new OutlineButton(
              child: new Text('Big no group'),
              onPressed: () async {
                var bigTextStyleInformation = BigTextStyleInformation(
                    "big Text no group ",
                    htmlFormatBigText: true,
                    contentTitle: '<b>Big Text no group</b>',
                    htmlFormatContentTitle: true,
                    summaryText: '<b>Big</b>',
                    htmlFormatSummaryText: true);
                var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                    'com.inthenou.app.channel.cancellations',
                    'Cancellations Notification',
                    'Notifications of Cancelled Events.',
                    importance: Importance.Max,
                    priority: Priority.High,
                    visibility: NotificationVisibility.Public,
                    styleInformation: bigTextStyleInformation);
                var platformChannelSpecifics = NotificationDetails(
                    androidPlatformChannelSpecifics, null);
                await flutterLocalNotificationsPlugin.show(
                    6, "Big Text No Group", "Big Text Description",
                    platformChannelSpecifics,
                    payload: "");
              },
            ),
            new OutlineButton(
              child: new Text('Better grouped'),
              onPressed: () async {
                var groupChannelId = 'com.inthenou.app.channel.cancellations';
                var groupKey = RECOMMENDATION_NOTIFICATION_GID;
                var groupChannelName = "Smart Notifications";
                var groupChannelDescription = "This is where Smart "
                    "Notifications reside";

                var firstNotificationAndroidSpecifics = AndroidNotificationDetails(
                    groupChannelId, groupChannelName, groupChannelDescription,
                    importance: Importance.Max,
                    priority: Priority.High,
                    groupKey: groupKey);
                var firstNotificationPlatformSpecifics =
                NotificationDetails(firstNotificationAndroidSpecifics, null);
                await flutterLocalNotificationsPlugin.show(70,
                    'Smart Notifications',
                    'Test 1',
                    firstNotificationPlatformSpecifics);
                await flutterLocalNotificationsPlugin.show(
                    71,
                    'Smart Notification',
                    'Test 2',
                    firstNotificationPlatformSpecifics);
                await flutterLocalNotificationsPlugin.show(
                    72,
                    'Smart Notification',
                    'Test 3',
                    firstNotificationPlatformSpecifics);
                await flutterLocalNotificationsPlugin.show(
                    73,
                    'Smart Notification',
                    'Test 4',
                    firstNotificationPlatformSpecifics);
                var lines = List<String>();
                lines.add('Smart Notification  Test1');
                lines.add('Smart Notification  Test2');
                lines.add('Smart Notification  Test3');
                lines.add('Smart Notification  Test4');
                var inboxStyleInformation = InboxStyleInformation(lines,
                    contentTitle: '2 messages', summaryText: 'Smart '
                        'Notifications');
                var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                    groupChannelId, groupChannelName, groupChannelDescription,
                    styleInformation: inboxStyleInformation,
                    groupKey: groupKey,
                    setAsGroupSummary: true);
                var platformChannelSpecifics =
                NotificationDetails(androidPlatformChannelSpecifics, null);
                await flutterLocalNotificationsPlugin.show(
                    74, 'Smart Notifications ', 'New Notifications',
                    platformChannelSpecifics);
              },
            ),
          ],
        ),
      ),
    );
  }

}