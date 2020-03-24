import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/background_handler.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/views/EventFeed/general_feed_view.dart';
import 'package:InTheNou/views/EventFeed/personal_feed_view.dart';
import 'package:InTheNou/views/InformoationBase/infobase_category_view.dart';
import 'package:InTheNou/views/Profile/profile_view.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';

NotificationAppLaunchDetails notificationAppLaunchDetails;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with flux.StoreWatcherMixin {
  NavigationStore navigationStore;

  final List<Widget> _children = [
    PersonalFeedView(),
    GeneralFeedView(),
    InfoBaseCategoryView(),
    ProfileView()
  ];

  @override
  void initState() {
    super.initState();
    BackgroundFetch.registerHeadlessTask(BackgroundHandler.onBackgroundFetch);
    initializeNotifications();
    checkLocationPermission();
    navigationStore = listenToStore(navigationToken);
  }

  void checkLocationPermission() async{
    await Geolocator().checkGeolocationPermissionStatus().then((value) {
      print(value);
      if(value == GeolocationStatus.denied ||
          value == GeolocationStatus.unknown){
        //show dialog
        showDialog(context: context, builder: (_){
          return AlertDialog(
            title:Text("Location Permission"),
            content: Text("This app neeeds to access your location to provide"
                " you with Smart Notifications. These take into consideration "
                "your location to send you a notification based on the time "
                "it take you to arrive to an event.\n This functionality can "
                "be turned off in the settings."),
            actions: <Widget>[
              FlatButton(
                child: Text("CONFIRM"),
                onPressed: (){
                  Navigator.of(context).pop();
                  LocationPermissions().requestPermissions(
                      permissionLevel: LocationPermissionLevel.locationAlways)
                      .then((value){
                        print(value);
                  });
                },
              )
            ],
          );
        });
      }
    });
  }

  void showGranted() async{
    await Geolocator().checkGeolocationPermissionStatus().then((value) {
      print(value);
      if(value == GeolocationStatus.denied ||
          value == GeolocationStatus.unknown){
        //show dialog
        showDialog(context: context, builder: (_){
          return AlertDialog(
            title:Text("Smart Notifications"),
            content: Text("TSmart notifications have been enabled.\n This "
                "functionality can be turned off in the settings."),
            actions: <Widget>[
              FlatButton(
                child: Text("CONFIRM"),
                onPressed: () {}
              )
            ],
          );
        });
      }
    });
  }

  void showDenied() async{
    await Geolocator().checkGeolocationPermissionStatus().then((value) {
      print(value);
      if(value == GeolocationStatus.denied ||
          value == GeolocationStatus.unknown){
        //show dialog
        showDialog(context: context, builder: (_){
          return AlertDialog(
            title:Text("Smart Notifications"),
            content: Text("TSmart notifications have been disabled.\n This "
                "functionality can be turned on in the settings."),
            actions: <Widget>[
              FlatButton(
                  child: Text("CONFIRM"),
                  onPressed: () {}
              )
            ],
          );
        });
      }
    });
  }

  void initializeNotifications() async {
    notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    var initializationSettingsAndroid = AndroidInitializationSettings
      ('ic_notification');
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    Navigator.of(context).pushNamed("/eventdetail",
        arguments: MapEntry(FeedType.GeneralFeed,int.parse(payload)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[navigationStore.destinationIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: navigateToAction,
        currentIndex: navigationStore.destinationIndex, // index of navigation
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        selectedItemColor: Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: Color.fromARGB(80, 0, 0, 0),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: new Text("Feed"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: new Text('Search Events'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.business),
              title: Text('Profile')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile')
          )
        ],
      ),
    );
  }

}

class NavigationStore extends flux.Store {
  int _destinationIndex = 0;
  NavigationStore(){
    triggerOnAction(navigateToAction, (int c) {
      _destinationIndex = c;
    });
  }
  int get destinationIndex => _destinationIndex;
}
final flux.Action<int> navigateToAction = new flux.Action<int>();
final flux.StoreToken navigationToken = new flux.StoreToken(new NavigationStore
  ());