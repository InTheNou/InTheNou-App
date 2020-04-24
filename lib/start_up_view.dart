import 'dart:io';

import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
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
  DialogService _dialogService = DialogService();

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
      builder: (BuildContext context, AsyncSnapshot<Cookie> session) {
        if(session.hasData){
          _userStore.getUser().then((user) {
            if (user == null) {
              Navigator.of(context).pushReplacementNamed("/login");
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                "/home", (Route<dynamic> route) => false,
              );
            }
          }).catchError((e){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showStartUpError(e);
            });
          });
        } else if(session.hasError){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showStartUpError(session.error);
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
                      child: Image.asset(
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
  void _showStartUpError(dynamic e) {
    String error;
    if (e.runtimeType == PlatformException) {
      if (e.code == GoogleSignIn.kSignInRequiredError) {
        Navigator.of(context).pushReplacementNamed("/login");
      } else if (e.code == GoogleSignIn.kNetworkError) {
        error = "Unable to sign in, Network unavailable.";
      } else {
        error = "Internal app error while Signing in";
      }
    } else {
      error = e.toString();
    }
    if(error != null){
      _dialogService.showDialog(
          type: DialogType.Error,
          title: "Startup failed",
          description: error);
    }

  }
}