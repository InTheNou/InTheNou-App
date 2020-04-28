import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/background/background_handler.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/stores/settings_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:geolocator/geolocator.dart';


class DebugSettingsView extends StatefulWidget {

  @override
  _DebugSettingsViewViewState createState() => new _DebugSettingsViewViewState();

}

class _DebugSettingsViewViewState extends State<DebugSettingsView>
  with flux.StoreWatcherMixin<DebugSettingsView>{

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
        title: Text("Debug Settings"),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Recommendation Check Interval",
                                          style: Theme.of(context).textTheme.subtitle1
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<int>(
                                      future: _settingsStore.recommendationInterval,
                                      builder: (BuildContext context, AsyncSnapshot<int> time) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: new DropdownButton<int>(
                                              value: time.data,
                                              style: Theme.of(context).textTheme.subtitle2,
                                              underline: Container(
                                                height: 2,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              items: _settingsStore.defaultTimes
                                                  .map<DropdownMenuItem<int>>((int value) {
                                                return DropdownMenuItem<int>(
                                                  value: value,
                                                  child: Text(value.toString()),
                                                );
                                              }).toList(),
                                              onChanged: (int newValue) {
                                                changeRecommendationIntervalAction(newValue);
                                              }
                                          ),
                                        );
                                      }),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Smart Notification Check Interval",
                                          style: Theme.of(context).textTheme.subtitle1
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<int>(
                                      future: _settingsStore.smartInterval,
                                      builder: (BuildContext context, AsyncSnapshot<int> time) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: new DropdownButton<int>(
                                              value: time.data,
                                              style: Theme.of(context).textTheme.subtitle2,
                                              underline: Container(
                                                height: 2,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              items: _settingsStore.defaultTimes
                                                  .map<DropdownMenuItem<int>>((int value) {
                                                return DropdownMenuItem<int>(
                                                  value: value,
                                                  child: Text(value.toString()),
                                                );
                                              }).toList(),
                                              onChanged: (int newValue) {
                                                changeSmartIntervalAction(newValue);
                                              }
                                          ),
                                        );
                                      }),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Cancellation Check Interval",
                                          style: Theme.of(context).textTheme.subtitle1
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<int>(
                                      future: _settingsStore.cancellationInterval,
                                      builder: (BuildContext context, AsyncSnapshot<int> time) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: new DropdownButton<int>(
                                              value: time.data,
                                              style: Theme.of(context).textTheme.subtitle2,
                                              underline: Container(
                                                height: 2,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              items: _settingsStore.defaultTimes
                                                  .map<DropdownMenuItem<int>>((int value) {
                                                return DropdownMenuItem<int>(
                                                  value: value,
                                                  child: Text(value.toString()),
                                                );
                                              }).toList(),
                                              onChanged: (int newValue) {
                                                changeCancellationIntervalAction(newValue);
                                              }
                                          ),
                                        );
                                      }),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Debug notifications",
                                          style: Theme.of(context).textTheme.subtitle1
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<bool>(
                                      future: _settingsStore.debugNotification,
                                      initialData: false,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<bool>toggle) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0,
                                              right: 8.0),
                                          child: new Switch(
                                              value: toggle.data,
                                              onChanged: (value)  async =>
                                                  changeDebugNotificationsAction(value)
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.all(4.0)),

                Card(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.only(top:16.0, bottom: 16.0,
                                      left: 8.0),
                                  child: Text("Clear Notification Data")
                              ),
                              onTap: () {
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Deleted Notification Data'),
                                    )
                                );
                                NotificationHandler.cancelAllSmartNotifications();
                                Utils.clearNotificationsPrefs();
                              }
                          ),
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
                                  child: Text("Clear Cache Data")
                              ),
                              onTap: () {
                                Utils.clearCache();
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Deleted Cache'),
                                    )
                                );
                              }
                          ),
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
                                  child: Text("User Privilege Change")
                              ),
                              onTap: () {
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Changed Local Privilege'),
                                    )
                                );
                                changeUserPrivilegeAction();
                              }
                          ),
                      ),
                    ],
                  ),
                ),

                Padding(padding: const EdgeInsets.all(8.0)),
                Text("Click this if you change the above times"),
                Card(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(top:16.0, bottom: 16.0,
                                    left: 8.0),
                                child: Text("Re-init Background tasks",
                                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                                        color: Theme.of(context).errorColor
                                    )
                                ),
                              ),
                              onTap: () async {
                                // Disable the background tasks
                                BackgroundHandler.restart();
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Background Tasks times '
                                          'changed.'),
                                    )
                                );
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
                                child: Text("Crash The App",
                                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                                        color: Theme.of(context).errorColor
                                    )
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed("crashy");
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
                                child: Text("Notifications",
                                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                                        color: Theme.of(context).errorColor
                                    )
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed
                                  ("notifications");
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