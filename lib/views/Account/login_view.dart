import 'package:InTheNou/stores/user_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:google_sign_in/google_sign_in.dart';

class LoginView extends StatefulWidget {

  LoginView() : super(key: ValueKey("LoginView"));

  @override
  _LoginViewState createState() => new _LoginViewState();

}

class _LoginViewState extends State<LoginView>
  with flux.StoreWatcherMixin<LoginView>{

  UserStore _userStore;

  @override
  void initState() {
    super.initState();
    _userStore = listenToStore(UserStore.userStoreToken);
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(_userStore.loginUser != null){
        _userStore.loginUser.then((user){
          if(user==null){
            // This means the backend recognizes this as a new user
            Navigator.of(context).pushNamedAndRemoveUntil(
              "/accountcreation", (Route<dynamic> route) => false,
            );
          }
          else{
            // The backend brought back a returning user info
            Navigator.of(context).pushNamedAndRemoveUntil(
              "/home", (Route<dynamic> route) => false,
            );
          }
          _userStore.loginUser = null;
        }).catchError((e){
          String error;
          if (e.runtimeType == PlatformException) {
            if (e.code == GoogleSignIn.kNetworkError) {
              error = "Unable to sign in, Network error.";
            } else {
              error = "Internal app error while Signing in";
            }
          } else if (e is DioError){
            error = e.toString();
          }
          Navigator.of(context).pop();
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Error'),
              content: Text(error?? e.toString()),
              actions: <Widget>[
                FlatButton(
                    child: const Text('OK'),
                    onPressed: (){
                      Navigator.of(context).pop();
                      resetLoginError();
                    }
                ),
              ],
            ),
          );
        });
      }
    });

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
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: GoogleSignInButton(
                key: ValueKey("LogInButton"),
                onPressed: () {
                  // Call the Auth service and wait for the user to be
                  // redirected back
                  callAuthAction();
                  showProgressBar();
                },
                darkMode: true,
              )
            ),
          ],
        ),
      ),
    );
  }
  
  void showProgressBar(){
    showDialog(context: context,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  value: null,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of
                    (context).accentColor),
                  strokeWidth: 8.0,
                )
            )
          ),
        );
      }
    );
  }
}