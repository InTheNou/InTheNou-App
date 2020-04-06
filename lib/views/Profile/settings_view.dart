import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/background_handler.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/home_page.dart';
import 'package:InTheNou/repos/user_repo.dart';
import 'package:InTheNou/stores/settings_store.dart';
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Card(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Default Notification",
                        style: Theme.of(context).textTheme.subtitle1
                    ),
                  ),
                ),
                FutureBuilder<int>(
                    future: _settingsStore.defaultNotificationTime,
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
                          color: Theme.of(context).accentColor
                        )
                      ),
                    ),
                    onTap: () async {
                      await logoutAction();
                      navigateToAction(0);
                      NotificationHandler.cancelAllSmartNotifications();
                      Utils.clearAllPreferences();
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
                          child: Text("Clear Notification Data")
                        ),
                        onTap: () {
                          NotificationHandler.cancelAllSmartNotifications();
                          Utils.clearNotificationsPrefs();
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
                            child: Text("User Privilege CHnage")
                        ),
                        onTap: () {
                          UserRepo.dummyUser.userPrivilege =
                              UserRepo.dummyUser.userPrivilege ==
                                  UserPrivilege.User?
                              UserPrivilege.EventCreator :
                              UserPrivilege.User;
                        }
                    )
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  ///
  /// Here we check if the permission has been changed after the lat time the
  /// setting was changed.
  /// If the Permission has been revoked and the user
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