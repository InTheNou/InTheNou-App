import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/background/background_handler.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/home_page.dart';
import 'package:InTheNou/stores/settings_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:geolocator/geolocator.dart';


class SettingsView extends StatefulWidget {

  @override
  _SettingsViewState createState() => new _SettingsViewState();

}

class _SettingsViewState extends State<SettingsView>
  with flux.StoreWatcherMixin<SettingsView>{

  SettingsStore _settingsStore;

  @override
  void initState() {
    super.initState();
    _settingsStore = listenToStore(settingsStoreToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Default Notification (minutes)",
                              style: Theme.of(context).textTheme.subtitle1
                          ),
                        ),
                      ),
                      FutureBuilder<int>(
                          future: _settingsStore.defaultNotificationTime,
                          builder: (BuildContext context, AsyncSnapshot<int> time) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButton<int>(
                                  value: time.data,
                                  underline: Container(
                                    height: 2,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  items: _settingsStore.defaultTimes
                                      .map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (int newValue) {
                                    changeNotificationTimeAction(newValue);
                                  }
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                Card(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Smart Notification",
                              style: Theme.of(context).textTheme.subtitle1
                          ),
                        ),
                      ),
                      FutureBuilder<bool>(
                          future: _settingsStore.smartNotificationEnabled,
                          initialData: false,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool>toggle) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0,
                                  right: 8.0),
                              child: new Switch(
                                  value: toggle.data,
                                  onChanged: (value)  async =>
                                      checkPermissionAndUpdate(value)
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                Card(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(top:16.0, bottom: 16.0,
                                    left: 8.0),
                                child: Text("Log Out",
                                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                                        color: Theme.of(context).errorColor
                                    )
                                ),
                              ),
                              onTap: () async {
                                await logoutAction();
                                // Move the HomePage navigator to the Personal feed for
                                // the next sign in
                                navigateToAction(0);
                                // Cancel all Preferences and Notifications of the
                                // current user
                                NotificationHandler.cancelAllSmartNotifications();
                                Utils.clearAllPreferences();
                                // Disable the background tasks
                                BackgroundHandler.onClickEnable(false);
                                Navigator.pushNamedAndRemoveUntil(
                                  context, "/login", (Route<dynamic> route) => false,);
                              }
                          )
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(top:16.0, bottom: 16.0,
                                    left: 8.0),
                                child: Text("Debug Settings",
                                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                                        color: Theme.of(context).errorColor
                                    )
                                ),
                              ),
                              onTap: () async {
                                Navigator.pushNamed(context, "/profile/settings/debug");
                              }
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      )
    );
  }

  /// Checks if the permission has been changed after the lat time the
  /// setting was changed.
  ///
  /// If the Permission has been revoked and the user then an Alerrt Dialog
  /// is shown
  void checkPermissionAndUpdate(bool setting) async{
    await Geolocator()
        .checkGeolocationPermissionStatus().then(
            (status) {
          if(status == GeolocationStatus.denied ||
              status == GeolocationStatus.unknown){
            toggleSmartAction(false);
            showDenied();
          } else {
            toggleSmartAction(setting);
          }
        });
  }

  /// Show an alert to the user if they try to enable SmartNotifications
  /// while not providing the Location Permission
  void showDenied() async{
    showDialog(context: context, builder: (_){
      return AlertDialog(
        title:Text("Smart Notifications"),
        content: Text("Smart notifications can be turned on after the "
            "Location Permission has been provided."),
        actions: <Widget>[
          FlatButton(
              child: Text("CONFIRM"),
              onPressed: () => Navigator.of(context).pop()
          )
        ],
      );
    });
  }
}