import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {

  @override
  _SettingsViewState createState() => new _SettingsViewState();

}

class _SettingsViewState extends State<SettingsView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SettingsView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("SettingsView", style: Theme
                .of(context)
                .textTheme
                .headline4,
            ),
          ],
        ),
      ),
    );
  }
}