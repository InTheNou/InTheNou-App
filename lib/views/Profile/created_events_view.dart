import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:InTheNou/views/widgets/created_event_card_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


/// The view for showing a list of [Event]s created by the current user
///
/// {@category View}
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
    refreshCreatedAction();
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
          builder: (context, AsyncSnapshot<List<Event>> createdEvents) {

            if(createdEvents.connectionState == ConnectionState.waiting){
              return _buildLoadingWidget();
            }
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
    return Scrollbar(
      child: RefreshIndicator(
        onRefresh: () => refreshCreatedAction(),
        child: ListView.builder(
            itemCount: createdEvents.length,
            itemBuilder: (context, index){
              Event _event = createdEvents[index];
              return CreatedEventCardImage(_event);
            }),
      ),
    );
  }

}