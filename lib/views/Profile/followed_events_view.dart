import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:InTheNou/views/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


class FollowedEventsView extends StatefulWidget {

  @override
  _FollowedEventsViewState createState() => new _FollowedEventsViewState();

}

class _FollowedEventsViewState extends State<FollowedEventsView>
  with flux.StoreWatcherMixin<FollowedEventsView>{

  UserStore _userStore;

  @override
  void initState() {
    super.initState();
    _userStore = listenToStore(UserStore.userStoreToken);
    refreshFollowedAction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Followed Events"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => refreshFollowedAction(),
          ),
        ],
      ),
      body:  FutureBuilder(
        future: _userStore.followedEvents,
        builder: (context, AsyncSnapshot<List<Event>> followedEvents) {

          if(followedEvents.connectionState == ConnectionState.waiting){
            return _buildLoadingWidget();
          }
          if(followedEvents.hasError){
            return _buildErrorWidget(followedEvents.error);
          } else if (followedEvents.hasData){
            return _buildResultsWidget(followedEvents.data);
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
        )
    );
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
        )
    );
  }

  Widget _buildResultsWidget(List<Event> followedEvents) {
    return Scrollbar(
      child: RefreshIndicator(
        onRefresh: () => refreshFollowedAction(),
        child: ListView.builder(
            itemCount: followedEvents.length,
            itemBuilder: (context, index){
              Event _event = followedEvents[index];
              return EventCard(_event, FeedType.Detail,
                interactionEnabled: false);
            }
        ),
      ),
    );
  }
}