import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:InTheNou/views/widgets/event_card_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

/// The view for showing a list of [Event]s that have been followed by the
/// current user and have ended
///
/// {@category View}
class HistoryEventsView extends StatefulWidget {

  @override
  _HistoryEventsViewState createState() => new _HistoryEventsViewState();

}

class _HistoryEventsViewState extends State<HistoryEventsView>
  with flux.StoreWatcherMixin<HistoryEventsView>{

  UserStore _userStore;

  @override
  void initState() {
    super.initState();
    _userStore = listenToStore(UserStore.userStoreToken);
    refreshHistoryAction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event History"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => refreshHistoryAction(),
          ),
        ],
      ),
      body:  FutureBuilder(
        future: _userStore.historyEvents,
        builder: (context, AsyncSnapshot<List<Event>> historyEvents) {

          if(historyEvents.connectionState == ConnectionState.waiting){
            return _buildLoadingWidget();
          }
          if(historyEvents.hasError){
            return _buildErrorWidget(historyEvents.error);
          } else if (historyEvents.hasData){
            return _buildResultsWidget(historyEvents.data);
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
        )
    );
  }

  Widget _buildResultsWidget(List<Event> historyEvents) {
    return Scrollbar(
      child: RefreshIndicator(
        onRefresh: () => refreshHistoryAction(),
        child: ListView.builder(
            itemCount: historyEvents.length,
            itemBuilder: (context, index){
              Event _event = historyEvents[index];
              return EventCardImage(_event, null);
            }
        ),
      ),
    );
  }
}