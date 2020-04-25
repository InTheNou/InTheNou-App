import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

const String PROFILE = "Profile";

class ProfileView extends StatefulWidget{

  ProfileView({Key key}) : super(key: PageStorageKey(key));

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfileView>
    with flux.StoreWatcherMixin<ProfileView>{

  UserStore _userStore;

  @override
  void initState() {
    super.initState();
    _userStore = listenToStore(UserStore.userStoreToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_userStore.user.firstName+ "'s Profile"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.of(context).pushNamed("/profile/settings"),
            ),
          ],
        ),
      body: Column(
        children: <Widget>[
          Card(
            margin:  EdgeInsets.only(top: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _userStore.user.fullName ,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        const Padding(padding: EdgeInsets.all(8.0)),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle1,
                              text: "Email: ",
                              children: <TextSpan>[
                                TextSpan(
                                    text: _userStore.user.email,
                                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                                        fontWeight: FontWeight.bold
                                    )
                                )
                              ]
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle1,
                              text: "Type of User: ",
                              children: <TextSpan>[
                                TextSpan(
                                    text: Utils.userRoleString(_userStore.user
                                        .role),
                                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                                        fontWeight: FontWeight.bold
                                    )
                                )
                              ]
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle1,
                              text: "Privilege level: ",
                              children: <TextSpan>[
                                TextSpan(
                                    text: Utils.userPrivilegeString(_userStore
                                        .user.userPrivilege),
                                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                                        fontWeight: FontWeight.bold
                                    )
                                )
                              ]
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Card(
            margin:  EdgeInsets.only(top: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: ()  {
                            refreshFollowedAction();
                            Navigator.of(context)
                              .pushNamed("/profile/followed_events");
                          },
                          child: ListTile(
                            title: Text("Followed Events"),
                            trailing: Icon(Icons.navigate_next),
                          ),
                        ),
                        InkWell(
                          onTap: ()  {
                            refreshFollowedAction();
                            Navigator.of(context)
                                .pushNamed("/profile/event_history");
                          },
                          child: ListTile(
                            title: Text("Events History"),
                            trailing: Icon(Icons.navigate_next),
                          ),
                        ),
                        InkWell(
                          onTap: ()  {
                            refreshFollowedAction();
                            Navigator.of(context)
                                .pushNamed("/profile/dismissed_events");
                          },
                          child: ListTile(
                            title: Text("Dismissed Events"),
                            trailing: Icon(Icons.navigate_next),
                          ),
                        ),
                        InkWell(
                          onTap: ()  {
                            Navigator.of(context)
                                .pushNamed("/profile/my_tags");
                          },
                          child: ListTile(
                            title: Text("My Tags"),
                            trailing: Icon(Icons.navigate_next),
                          ),
                        ),
                        Visibility(
                          visible: _userStore.user.userPrivilege != UserPrivilege.User,
                          child: const Divider(),
                        ),
                        Visibility(
                          visible: _userStore.user.userPrivilege != UserPrivilege.User,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed("/profile/created_events");
                              refreshCreatedAction();
                            },
                            child: ListTile(
                              title: Text("Created Events"),
                              trailing: Icon(Icons.navigate_next),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      )
    );
  }
  
}