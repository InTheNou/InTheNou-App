import 'dart:convert';
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/background_handler.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/stores/settings_store.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'background/notification_handler.dart';

NotificationAppLaunchDetails notificationAppLaunchDetails;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with flux.StoreWatcherMixin {
  NavigationStore navigationStore;
  SharedPreferences prefs;

  final List<Widget> _children = [
    PersonalFeedView(),
    GeneralFeedView(),
    InfoBaseCategoryView(),
    ProfileView()
  ];

  /// Initializing the Background tasks library with the headless tas  to be
  /// used when the app is terminated. Full implementation can be seen in
  /// [BackgroundHandler]
  @override
  void initState() {
    super.initState();
    BackgroundHandler.initPlatformState();
    BackgroundFetch.registerHeadlessTask(BackgroundHandler.onBackgroundFetch);
    Utils.checkSharedPrefs();
    initializeNotifications();
    checkLocationPermission();
    navigationStore = listenToStore(navigationToken);
    flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Checks if the permission has been granted using the [GeolocationStatus.
  ///
  /// if it has not and the user has decided to not be asked again, then
  /// nothing is done.
  /// If the user has not decided to not be asked again then we show the
  /// rationale for enabling the permission. Then we wait for the [PermissionStatus]
  /// result and handle it in [handlePermissionResult].
  void checkLocationPermission() async{
    prefs = await SharedPreferences.getInstance();
    // Check status of permission
    await Geolocator().checkGeolocationPermissionStatus().then((value) {
      if((value == GeolocationStatus.denied ||
          value == GeolocationStatus.unknown) &&
          prefs.getBool(ASK_LOCATION_PERMISSION_KEY)){
        // Show rationale
        showDialog(context: context,
            barrierDismissible: false,
            builder: (_){
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
                  // Show Permission screen
                  LocationPermissions().requestPermissions(
                      permissionLevel: LocationPermissionLevel.locationAlways)
                      .then((value) => handlePermissionResult(value));
                },
              )
            ],
          );
        });
      }
    });
  }

  ///Handles the user's choice of location permission.
  ///
  /// The [result] indicates if it was granted, based on this we enable
  /// or disable the Smart Notification using the [toggleSmartAction]  and
  /// show the appropriate dialog.
  void handlePermissionResult(PermissionStatus result){
    if(result == PermissionStatus.granted){
      showGranted();
      toggleSmartAction(true);
    } else {
      showDenied();
      toggleSmartAction(false);
    }
  }

  /// We inform the user that they have enabled Smart Notifications
  void showGranted() async{
    showDialog(context: context,
        barrierDismissible: false,
        builder: (_){
          return AlertDialog(
            title:Text("Smart Notifications"),
            content: Text("TSmart notifications have been enabled.\n This "
                "functionality can be turned off in the settings."),
            actions: <Widget>[
              FlatButton(
                  child: Text("CONFIRM"),
                  onPressed: ()  => Navigator.of(context).pop()
              )
            ],
          );
        });
  }

  /// Notifies the user they have disabled Smart Notifications from not
  /// allowing the location permission.
  ///
  /// If the user has chosen not to provide the Location Permission then we
  /// show them a warning that this disables the Smart Notification.
  /// If they desire not to be asked again for the permission this is also
  /// taken into consideration.
  void showDenied() async{
    showDialog(context: context,
        barrierDismissible: false,
        builder: (_){
          return AlertDialog(
            title:Text("Smart Notifications"),
            content: Text("Smart notifications have been disabled.\n This "
                "functionality can be turned on in the settings after the "
                "Location Permission has been provided."),
            actions: <Widget>[
              // If the user doesn't want to provide the location permission
              // and desires not to be asked again then we save that selection.
              FlatButton(
                  child: Text("DISMISS FOREVER"),
                  onPressed: () {
                    prefs.setBool(ASK_LOCATION_PERMISSION_KEY, false);
                    Navigator.of(context).pop();
                  }
              ),
              FlatButton(
                  child: Text("CONFIRM"),
                  onPressed: () => Navigator.of(context).pop()
              ),
            ],
          );
        });
  }

  /// This methods gets ran evey time the app is started to make sure the
  /// Notifications are initialized adn setup.
  void initializeNotifications() async {
    notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    var initializationSettingsAndroid = AndroidInitializationSettings
      ('ic_notification');
    // Here is where we could add the iOS settings when the platform gets
    // supported by the app
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, null);
    // We finally initialize the Notifications and provide the callback
    // function that will be ued.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  /// Callback for when a Notification is clicked by the user.
  ///
  /// Here can handle multiple types of notifications by analyzing the
  /// [payload].
  Future onSelectNotification(String payload) async {
    NotificationObject notification =
    NotificationObject.fromJson(jsonDecode(payload));

    if(notification.type == NotificationType.SmartNotification){
      Navigator.of(context).pushNamed("/eventdetail",
          arguments: MapEntry(FeedType.GeneralFeed,int.parse(notification.payload)));
      return;
    }
    if(notification.type == NotificationType.DefaultNotification){
      Navigator.of(context).pushNamed("/eventdetail",
          arguments: MapEntry(FeedType.GeneralFeed,int.parse(notification.payload)));
      return;
    }
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