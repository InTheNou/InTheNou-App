import 'package:InTheNou/models/event.dart';
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => refreshCreatedAction(),
          ),
        ],
      ),
        body:  FutureBuilder(
          future: _userStore.createdEvents,
          builder: (BuildContext context,
              AsyncSnapshot<List<Event>> createdEvents) {
            if(createdEvents.hasError){
              return _buildErrorWidget(createdEvents.error);
            } else if (createdEvents.hasData){
              return _buildResultsWidget(createdEvents.data);
            } else {
              return _buildLoadingWidget();
            }
          },
        )
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(error,
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
          ],
        ));
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 100,
                height: 100,
                child: CircularProgressIndicator()),
          ],
        ));
  }

  Widget _buildResultsWidget(List<Event> createdEvents) {
    return ListView.builder(
        itemCount: createdEvents.length,
        itemBuilder: (context, index){
          Event _event = createdEvents[index];
          return Card(
              key: ValueKey(_event.UID+10),
              margin: EdgeInsets.only(top: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                      '/eventdetail',
                      arguments: _event.UID
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
                            Visibility(
                              visible: _event.endDateTime.isAfter(DateTime.now())
                               && _event.status == "active",
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    ButtonTheme(
                                        minWidth: 120.0,
                                        child: RaisedButton(
                                            child: Text("CANCEL"),
                                            color: Theme.of(context).accentColor,
                                            textColor: Theme.of(context).canvasColor,
                                            onPressed: () =>
                                                _showCancelConfirmation(_event)
                                        )
                                    )
                                  ]
                              ),
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

  void _showCancelConfirmation(Event _event){
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
                onPressed: () async{
                  Navigator.of(context).pop();
                  await cancelEventAction(_event);
                  _userStore.cancelEventResult.then((value) {
                    print(value);
                    if(value != null){
                      if(!value){
                        _showCancelError();
                      }
                    }
                    refreshCreatedAction();
                  });
                },
              )
            ],
          );
        }
    );
  }

  void _showCancelError() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: const Text('Error'),
              content: Text("Unable to Cancel Event Please try again."),
              actions: <Widget>[
                FlatButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                ),
              ],
            ),
      );
    });
  }

}