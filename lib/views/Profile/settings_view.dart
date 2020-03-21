import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {

  @override
  _SettingsViewState createState() => new _SettingsViewState();

}

class _SettingsViewState extends State<SettingsView> {

  List<int> defaultNotifTimes = [
    5, 10, 15, 20, 30
  ];

  int selected = 30;
  bool smartNotification = false;

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
                  child: Text(
                      "Default Notification"
                  ),
                ),
                DropdownButton<int>(
                  value: selected,
                  style: Theme.of(context).textTheme.subtitle2,
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                  items: defaultNotifTimes
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int newValue) {
                    setState(() {
                      selected = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          Card(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                      "Smart Notification"
                  ),
                ),
                Switch(
                  value: smartNotification,
                  onChanged: (value) {
                    setState(() {
                      smartNotification = value;
                    });
                  },
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}