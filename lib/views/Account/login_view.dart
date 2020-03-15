import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {

  @override
  _LoginViewState createState() => new _LoginViewState();

}

class _LoginViewState extends State<LoginView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LoginView"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("LoginView",style: Theme.of(context).textTheme.headline4),
            RaisedButton(
              child: Text('Go to personal feed'),
              onPressed: () {
                Navigator.of(context).pushNamed('/personalfeed');
              },
            )
          ],
        ),
      ),
    );
  }
}