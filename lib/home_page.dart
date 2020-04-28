import 'dart:convert';
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/background_handler.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/stores/settings_store.dart';
import 'package:InTheNou/views/EventFeed/feed_view.dart';
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
  DialogService _dialogService = DialogService();

  final List<Widget> _children = [
    FeedView(type: FeedType.PersonalFeed),
    FeedView(type: FeedType.GeneralFeed),
    InfoBaseCategoryView(key: PageStorageKey("InfoBaseCategoryView")),
    ProfileView(key: PageStorageKey("ProfileView"))
  ];
  final PageStorageBucket bucket = PageStorageBucket();

  /// Initializing the Background tasks library with the headless tas  to be
  /// used when the app is terminated. Full implementation can be seen in
  /// [BackgroundHandler]
  @override
  void initState() {
    super.initState();
    Utils.checkSharedPrefs();
    BackgroundHandler.initBackgroundTasks();
    BackgroundFetch.registerHeadlessTask(BackgroundHandler.onBackgroundFetch);
    initializeNotifications();
    checkLocationPermission();
    navigationStore = listenToStore(navigationToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: _children[navigationStore.destinationIndex],
        bucket: bucket,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: navigateToAction,
        currentIndex: navigationStore.destinationIndex,
        // index of navigation
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        selectedItemColor: Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: Color.fromARGB(80, 0, 0, 0),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: new Text("Personal Feed"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            title: new Text('General Feed'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.business),
              title: Text('Information Basee')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile')
          )
        ],
      ),
    );
  }

  /// Checks if the permission has been granted using the [GeolocationStatus.
  ///
  /// if it has not and the user has decided to not be asked again, then
  /// nothing is done.
  /// If the user has not decided to not be asked again then we show the
  /// rationale for enabling the permission. Then we wait for the [PermissionStatus]
  /// result and handle it in [handlePermissionResult].
  void checkLocationPermission() async {
    prefs = await SharedPreferences.getInstance();
    // Check status of permission
    await Geolocator().checkGeolocationPermissionStatus().then((value) {
      if ((value == GeolocationStatus.denied ||
          value == GeolocationStatus.unknown) &&
          prefs.getBool(ASK_LOCATION_PERMISSION_KEY)) {
        // Show rationale
        showDialog(context: context,
            barrierDismissible: false,
            builder: (_) {
              return AlertDialog(
                title: Text("Location Permission"),
                content: Text(
                    "This app neeeds to access your location to provide"
                        " you with Smart Notifications. These take into consideration "
                        "your location to send you a notification based on the time "
                        "it take you to arrive to an event.\n This functionality can "
                        "be turned off in the settings."),
                actions: <Widget>[
                  FlatButton(
                    child: Text("CONFIRM"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Show Permission screen
                      LocationPermissions().requestPermissions(
                          permissionLevel: LocationPermissionLevel
                              .locationAlways)
                          .then((value) => handlePermissionResult(value));
                    },
                  )
                ],
              );
            });
      } else{
        if(prefs.getBool(SMART_NOTIFICATION_KEY) == null )
        prefs.setBool(SMART_NOTIFICATION_KEY, true);
      }
    });
  }

  ///Handles the user's choice of location permission.
  ///
  /// The [result] indicates if it was granted, based on this we enable
  /// or disable the Smart Notification using the [toggleSmartAction]  and
  /// show the appropriate dialog.
  void handlePermissionResult(PermissionStatus result) {
    if (result == PermissionStatus.granted) {
      prefs.setBool(SMART_NOTIFICATION_KEY, true);
      showGranted();
    } else {
      prefs.setBool(SMART_NOTIFICATION_KEY, false);
      showDenied();
    }
  }

  /// We inform the user that they have enabled Smart Notifications
  void showGranted() async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text("Smart Notifications"),
            content: Text("Smart notifications have been enabled.\n This "
                "functionality can be turned off in the settings."),
            actions: <Widget>[
              FlatButton(
                  child: Text("CONFIRM"),
                  onPressed: () => Navigator.of(context).pop()
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
  void showDenied() async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text("Smart Notifications"),
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
    var initializationSettingsAndroid = AndroidInitializationSettings
      ("ic_notification");
    // Here is where we could add the iOS settings when the platform gets
    // supported by the app
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, null);
    // We finally initialize the Notifications and provide the callback
    // function that will be ued.
    var result = await flutterLocalNotificationsPlugin.initialize
      (initializationSettings,
        onSelectNotification: onSelectNotification);
    if(!result){
      _dialogService.showDialog(
          type: DialogType.Error, title: "Failed to Enable Notifications",
          description: "This is bad.");
      throw StateError("Unable to initialize notifications");
    }
  }

  /// Callback for when a Notification is clicked by the user.
  ///
  /// Here can handle multiple types of notifications by analyzing the
  /// [payload].
  Future onSelectNotification(String payload) async {
    notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if(notificationAppLaunchDetails.didNotificationLaunchApp){
      NotificationObject notification =
      NotificationObject.fromJson(jsonDecode(payload));
      if (notification.type == NotificationType.SmartNotification) {
        Navigator.of(context).pushNamed("/eventdetail",
            arguments: int.parse(notification.payload));
        return;
      } else if (notification.type == NotificationType.DefaultNotification) {
        Navigator.of(context).pushNamed("/eventdetail",
            arguments: int.parse(notification.payload));
        return;
      } else if (notification.type == NotificationType.Cancellation) {
        Navigator.of(context).pushNamed("/eventdetail",
            arguments: int.parse(notification.payload));
        return;
      }
    }
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