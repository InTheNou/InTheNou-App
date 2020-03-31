import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/event_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


class CreatedEventsView extends StatefulWidget {

  @override
  _CreatedEventsViewState createState() => new _CreatedEventsViewState();

}

class _CreatedEventsViewState extends State<CreatedEventsView>
  with flux.StoreWatcherMixin<CreatedEventsView>{

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
        title: Text("Created Events"),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody(){
    if(_userStore.isCreatedLoading){
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if(_userStore.createdEventError !=null){
        showErrorDialog(_userStore.createdEventError);
      }
      return ListView.builder(
          itemCount: _userStore.createdEvents.length,
          itemBuilder: (context, index){
            Event _event = _userStore.createdEvents[index];
            return Card(
                key: ValueKey(_event.UID+10),
                margin: EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () {
                    openEventDetail(_event.UID);
                    Navigator.of(context).pushNamed(
                        '/eventdetail',
                        arguments: null
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left:
                    8.0, right: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _event.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(bottom: 4.0)),
                              Text(
                                  _event.getDurationString(),
                                  style: Theme.of(context).textTheme.bodyText1
                              ),
                              const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                              Text(
                                  _event.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.subtitle2
                              ),
                              const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    ButtonTheme(
                                        minWidth: 120.0,
                                        child: RaisedButton(
                                            child: Text("CANCEL"),
                                            color: Theme.of(context).accentColor,
                                            textColor: Theme.of(context).canvasColor,
                                            onPressed: () =>
                                                showCancelConfirmation(context,
                                                    _event)
                                        )
                                    )
                                  ]
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            );
          });
    }
  }

  Future showErrorDialog(String errorText) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text(errorText),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                clearErrorAction(FeedType.PersonalFeed);
              },
            ),
          ],
        ),
      );
    });
  }

  void showCancelConfirmation(BuildContext context, Event _event){
    showDialog(context: context,
      barrierDismissible: true,
      builder: (_){
        return AlertDialog(
          title: Text(
              "Event Cancellation"
          ),
          content: Text(
            "Are you sure you want to cancel this event? \nThis action "
                "can't be undone."
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("CONFIRM"),
              textColor: Theme.of(context).accentColor,
              onPressed: () {
                Navigator.of(context).pop();
                cancelEventAction(_event);
                refreshCreatedAction();
              },
            )
          ],
        );
      }
    );
  }

}