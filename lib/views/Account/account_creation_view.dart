import 'package:InTheNou/assets/validators.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:InTheNou/assets/colors.dart';

/// The view for creating account for new users
///
/// The user selects 5 Tags of interest and then their account can be created.
///
/// {@category View}
class AccountCreationView extends StatefulWidget {

  @override
  _AccountCreationViewState createState() => new _AccountCreationViewState();

}

class _AccountCreationViewState extends State<AccountCreationView>
  with flux.StoreWatcherMixin<AccountCreationView>{

  final _formKey = GlobalKey<FormState>();
  var _autoValidate = false;
  UserStore _userStore;
  DialogService _dialogService = DialogService();

  @override
  void initState() {
    super.initState();
    _userStore = listenToStore(UserStore.userStoreToken);
    getTagsAction();
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(_userStore.accountCreationFinished != null){
        _userStore.accountCreationFinished.then((finish){
          if(finish){
            // The backend brought back user info so route to the home screen
            Navigator.of(context).pushNamedAndRemoveUntil(
              "/home", (Route<dynamic> route) => false,
            );
            _userStore.accountCreationFinished = Future.value(false);
          }
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
                  // The Role selection was removed from the requirements so
                  // this is left here for future development

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
                    child: Text("Select 5 tags of interest: "
                        "${_userStore.selectedTags.length}/5",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: Theme.of(context).canvasColor
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Visibility(
                      visible: _userStore.tagsString.isNotEmpty,
                      child: Text(_userStore.tagsString,
                        style: TextStyle(
                            color: Colors.white
                        ),),
                    ),
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
                              autofocus: false,
                              maxLength: 50,
                              maxLengthEnforced: true,
                              decoration: InputDecoration(
                                  hintText: "Search Tags...",
                                  border: InputBorder.none,
                                  counterStyle: TextStyle(height: double.minPositive,),
                                  counterText: ""
                              ),
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
                        color: primaryColor[50],
                        child: Text(
                          "Create Your Account",
                          style: Theme.of(context).accentTextTheme.headline6
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

  /// Validates the information provided by the user.
  ///
  /// If the user hasn't selected the appropriate number of tags then the
  /// user is shown a notice using [showTagWarning] otherwise
  /// they are asked to confirm their input inside the [createUserAction] call.
  /// If they choose to confirm then their account is created.
  void validate(){
    if(_formKey.currentState.validate() &&
        Validators.validateCreationTags(_userStore.selectedTags)){
      createUserAction();
    }
    else{
      if(_userStore.selectedTags.length != 5){
        showTagWarning();
      }
      _autoValidate = true;
    }
  }

  /// Shows an [AlertDialog] informing the user hasn't selected the correct
  /// number of [Tag]s.
  void showTagWarning(){
    _dialogService.showDialog(
        type: DialogType.Alert,
        title: "Incorrect number of Tags",
        description: "Please 5 Tags that best describe your interests");
  }

}