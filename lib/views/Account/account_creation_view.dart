import 'package:flutter/material.dart';

class AccountCreationView extends StatefulWidget {

  @override
  _AccountCreationViewState createState() => new _AccountCreationViewState();

}

class _AccountCreationViewState extends State<AccountCreationView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AccountCreationView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("AccountCreationView", style: Theme
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