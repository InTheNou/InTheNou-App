import 'dart:io';

import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:google_sign_in/google_sign_in.dart';

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
    fetchSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userStore.session,
      builder: (BuildContext context, AsyncSnapshot<Cookie> snapshot) {
        if(snapshot.hasError){
          showError(snapshot.error);
        } else if(snapshot.hasData){
          _userStore.getUser().then((user) {
            if(user == null){
              Navigator.of(context).pushReplacementNamed("/accountcreation");
            } else {
              Navigator.of(context).pushReplacementNamed("/home");
            }
          });
        }
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
      },
    );
  }

  /// Shows the user any errors during startup of the app.
  void showError(Exception e) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String error;
      if (e is PlatformException) {
        if (e.code == GoogleSignIn.kSignInRequiredError) {
          Navigator.of(context).pushReplacementNamed("/login");
        } else if (e.code == GoogleSignIn.kNetworkError) {
          error = "Unable to sign in, Network error.";
        } else {
          error = "Internal app error while Signing in";
        }
      }
      if(error != null){
        showDialog<String>(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(
                title: const Text('Error'),
                content: Text(error),
                actions: <Widget>[
                  FlatButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        resetLoginError();
                      }
                  ),
                ],
              ),
        );
      }
    });
  }
}