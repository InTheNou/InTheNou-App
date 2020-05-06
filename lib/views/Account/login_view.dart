import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:google_sign_in/google_sign_in.dart';

/// The view for logging into the app using a Google account
///
/// If a Google account was selected but the login process didn't complete,
/// the user will be shown the account they are currently signed in with and
/// they can choose to sign out to use another Google Account.
///
/// {@category View}
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
    _userStore.getAccount();
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
        });
      }
    });

    return FutureBuilder(
      future: _userStore.account,
      builder: (BuildContext context, AsyncSnapshot<GoogleSignInAccount> account) {
        return Scaffold(
          backgroundColor: primaryColor,
          body: Center(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Container(
                    height: 450,
                    width: 350,
                    child: Image.asset(
                      "lib/assets/InTheNou_logo.png",
                      fit: BoxFit.fitWidth,
                      semanticLabel: "InTheNou App Logo",
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                  ),
                ),
                GoogleSignInButton(
                  key: ValueKey("LogInButton"),
                  text: account.hasData ? "Continue with Google":
                  "Sign in with Google",
                  onPressed: () {
                    // Call the Auth service and wait for the user to be
                    // redirected back
                    callAuthAction();
                  },
                  darkMode: true,
                ),
                Expanded(
                  flex: 2,
                  child: Visibility(
                    visible: account.hasData,
                    child:Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.all(8),
                              child: RichText(
                                  text: TextSpan(
                                      style: Theme.of(context).accentTextTheme.subtitle1,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "Currently Signed in as:\n"
                                        ),
                                        TextSpan(
                                          text: "${_userEmail(account
                                              .data)}",
                                          style: Theme.of(context).accentTextTheme.subtitle1.copyWith(
                                              fontWeight: FontWeight.bold
                                          ),
                                        )
                                      ]
                                  )
                              ),
                            ),
                          ),
                          FlatButton(
                            child: Text("Sign Out"),
                            textColor: Theme.of(context).errorColor,
                            onPressed: () => googleSignOut(),
                          )
                        ]
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        },
    );
  }

  String _userEmail(GoogleSignInAccount account){
    return account == null? "" : account.email;
  }
}