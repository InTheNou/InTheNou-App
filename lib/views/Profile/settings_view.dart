import 'package:InTheNou/home_page.dart';
import 'package:InTheNou/stores/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


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
                            onChanged: (value) => toggleSmartAction(value)
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
                    onTap: () {
                      logoutAction();
                      navigateToAction(0);
                      Navigator.pushNamedAndRemoveUntil(
                        context, "/login", (Route<dynamic> route) => false,);
                    }
                  )
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}