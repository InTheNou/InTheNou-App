import 'package:InTheNou/assets/validators.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class AccountCreationView extends StatefulWidget {

  @override
  _AccountCreationViewState createState() => new _AccountCreationViewState();

}

class _AccountCreationViewState extends State<AccountCreationView>
  with flux.StoreWatcherMixin<AccountCreationView>{

  final _formKey = GlobalKey<FormState>();
  var _autoValidate = false;
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
            // Show a progress bar while the backend creates the Account
            showCreatingAccountLoading();
          }
          else{
            // The backend brought back user info
            Navigator.of(context).pushNamedAndRemoveUntil(
              "/home", (Route<dynamic> route) => false,
            );
            _userStore.loginUser = null;
          }
        }).catchError((e){
          showErrorDialog(e);
        });
      }
    });
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "lib/assets/InTheNou_logo.png",
                          width: 275,
                          semanticLabel: "InTheNou App Logo",
                        ),
                      ],
                    ),
                  ),
//                Padding(
//                  padding: const EdgeInsets.only(left: 8.0),
//                  child: Text("Role",
//                      style: Theme.of(context).textTheme.subtitle1.copyWith(
//                          color: Theme.of(context).canvasColor
//                      )),
//                ),
//                Card(
//                    child: Padding(
//                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
//                      child: DropdownButtonFormField<UserRole>(
//                        value: _userStore.selectedRole,
//                        decoration: InputDecoration.collapsed(
//                            hintText: "Role"),
//                        autovalidate: _autoValidate,
//                        items: _userStore.userRoles.map((UserRole role) {
//                          return DropdownMenuItem<UserRole>(
//                              value: role,
//                              child: Text(Utils.userRoleString(role)));
//                        }).toList(),
//                        onChanged: (value) => selectRoleAction(value),
//                        validator: (value) =>
//                        value == null? "Please choose a Role" : null,
//                      ),
//                    )
//                ),
                  const Padding(padding: EdgeInsets.only(top:16),),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text("Select 5 tags of interest:",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: Theme.of(context).canvasColor
                        )),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.all(8.0)),
                        Icon(Icons.search),
                        const Padding(padding: EdgeInsets.only(
                            left: 16.0)),
                        Expanded(
                          child: TextField(
                              decoration: InputDecoration.collapsed(
                                hintText:  "Serach Tags",),
                              onChanged: (String value) => searchedTagAction(value.trim())
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: kElevationToShadow[2]
                    ),
                    constraints: BoxConstraints(
                        maxHeight: 325.0,
                        minHeight: 50.0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _userStore.searchTags.keys.length,
                        itemBuilder: (BuildContext context, int index){
                          MapEntry<Tag,bool> tag = _userStore.searchTags
                              .entries.elementAt(index);
                          return CheckboxListTile(
                            title: Text(tag.key.name),
                            value: tag.value,
                            onChanged: (bool value){
                              toggleTagAction(MapEntry(tag.key, value));
                            },
                          );
                        })
                      ),
                  const Padding(padding: EdgeInsets.only(top:16),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          "Create Your Account",
                          style: Theme.of(context).textTheme.headline6.copyWith(
                              color: Theme.of(context).canvasColor
                          ),
                        ),
                        onPressed: () => validate()
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }

  /// Shows the user any account creation errors.
  void showErrorDialog(Exception e){
    Navigator.of(context).pop();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(e.toString()),
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
  }

  /// Validates the information provided by the user.
  ///
  /// If the user hasn't selected the appropriate number of tags then the
  /// user is shown a notice using [showTagWarning] otherwise
  /// they are asked to confirm their input using [showSubmitConfirmation].
  /// If they choose to confirm then their account is created by calling
  /// [createUserAction].
  void validate(){
    if(_formKey.currentState.validate() &&
        Validators.validateCreationTags(_userStore.selectedTags)){
      showSubmitConfirmation().then((value) {
        if(value != null && value){
          createUserAction();
        }
      });
    }
    else{
      if(_userStore.selectedTags.length != 5){
        showTagWarning();
      }
      _autoValidate = true;
    }
  }

  /// Shows the user a confirmation [AlertDialog] before creating their account
  ///
  /// If the user dismissed the AlertDialog then this returns null and the
  /// account creation does not proceed. Otherwise the user clicks Confirm
  /// which returns true and the account creation continues.
  Future<bool> showSubmitConfirmation(){
    return showDialog<bool>(context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Confirm"),
            content: Text(
                "Your account will be created now with these interests."
            ),
            actions: <Widget>[
              RaisedButton(
                textColor: Theme.of(context).canvasColor,
                color: Theme.of(context).primaryColor,
                child: Text(
                    "CONFIRM"
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              Padding(padding: EdgeInsets.only(left: 8.0),)
            ],
          );
        }
    );
  }

  /// Shows a loading screen to the user while the account is created in the
  /// backend.
  void showCreatingAccountLoading(){
    showDialog(context: context,
        builder: (_) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: null,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of
                            (context).accentColor),
                          strokeWidth: 8.0,
                        )
                    ),
                    const Padding(padding: EdgeInsets.all(16.0)),
                    Text("We are getting your account ready!",
                    style: Theme.of(context).textTheme.headline5.copyWith(
                        color: Theme.of(context).canvasColor)
                    )
                  ],
                )
            ),
          );
        }
    );
  }

  /// Shows an [AlertDialog] informing the user hasn't selected the correct
  /// number of [Tag]s.
  void showTagWarning(){
    showDialog(context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Incorrect number of Tags"),
            content: Text(
                "Please 5 Tags that best your interests"
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text(
                    "CONFIRM"
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        }
    );
  }

}