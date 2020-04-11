import 'dart:io';

import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class StartUpView extends StatefulWidget {

  @override
  _StartUpViewState createState() => new _StartUpViewState();

}

class _StartUpViewState extends State<StartUpView>
    with flux.StoreWatcherMixin<StartUpView> {
  UserStore _userStore;

  @override
  void initState() {
    super.initState();
    _userStore = listenToStore(UserStore.userStoreToken);
    _userStore.getSession().then((Cookie session) {
      if(session==null){
        Navigator.of(context).pushReplacementNamed("/login");
      }
      else{
        _userStore.getUser().then((user) {
          print(user);
          if(user == null){
            Navigator.of(context).pushReplacementNamed("/accountcreation");
          } else {
            Navigator.of(context).pushReplacementNamed("/home");
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 450,
              width: 350,
              child: Image.asset(
                "lib/assets/InTheNou_logo.png",
                fit: BoxFit.fitWidth,
                semanticLabel: "InTheNou App Logo",
              ),
            ),
            Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child:  Image.asset(
                  "lib/assets/AlphaCode_logo.png",
                  width: 150,
                  semanticLabel: "AlphaCode Logo",
                )
            ),
          ],
        ),
      )
    );
  }
}