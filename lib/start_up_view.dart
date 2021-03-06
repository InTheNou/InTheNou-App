import 'dart:io';
import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:InTheNou/home_page.dart';
import 'package:InTheNou/views/Account/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// The initial view whenever the user loads into the app.
///
/// It does the verification of a current session and routes to the
/// [HomePage] or [LoginView] respectively.
///
/// {@category View}
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
          // Checks the cached data for a user object
          _userStore.getUser().then((user) {
            if (user != null) {
              if(user.fullName == "None"){
                Navigator.of(context).pushReplacementNamed("/login");
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  "/home", (Route<dynamic> route) => false,
                );
              }
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
            backgroundColor: primaryColor,
            body: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 450,
                    width: 350,
                      child: FlatButton(
                        child: Image.asset(
                          "lib/assets/InTheNou_logo.png",
                          fit: BoxFit.fitWidth,
                          semanticLabel: "InTheNou App Logo",
                        ),
                        onPressed: () => _showHostInput(),
                      )
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Image.asset(
                        "lib/assets/AlphaCode_logo.png",
                        width: 150,
                        semanticLabel: "AlphaCode Logo",
                      ),
                  ),
                ],
              ),
            )
        );
      },
    );
  }
  String url = "https://X/API";
  ApiConnection apiConnection = ApiConnection();

  void _showHostInput(){
    showDialog(
        context: context,
        builder: (_){
          return AlertDialog(
            content: TextField(
              controller: TextEditingController(
                text: url
              ),
              onChanged: (value){
                url = value;
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Connect"),
                onPressed: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString(API_ROUTE_KEY, url);
                  await apiConnection.init();
                  Navigator.of(context).pop();
                  fetchSession();
                },
              )
            ],
          );
        }
    );
  }

  /// Shows the user any errors during startup of the app.
  ///
  /// If the error is [GoogleSignIn.kSignInRequiredError] then it routes to
  /// the [LoginView].
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