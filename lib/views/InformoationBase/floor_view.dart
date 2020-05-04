import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/InformoationBase/room_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

/// The view for showing detailed information about a selected [Floor]
///
/// {@category View}
class FloorView extends StatefulWidget {

  @override
  _FloorViewState createState() => new _FloorViewState();

}

class _FloorViewState extends State<FloorView>
    with flux.StoreWatcherMixin<FloorView>{

  InfoBaseStore _infoBaseStore;

  @override
  void initState() {
    super.initState();
    _infoBaseStore = listenToStore(InfoBaseStore.infoBaseToken);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_infoBaseStore.selectedFloor.floorName),
        ),
        body: FutureBuilder(
          future: _infoBaseStore.roomsInBuilding,
          builder: (BuildContext context, AsyncSnapshot<dynamic> roomsInBuilding) {
            if(roomsInBuilding.hasData){
              return _buildBody(roomsInBuilding.data);
            }
            else if(roomsInBuilding.hasError){
              return _buildErrorWidget(roomsInBuilding.error.toString());
            }
            return _buildLoadingWidget();
          },
        )
    );

  }

  Widget _buildBody(List<Room> roomsInBuilding){
    return ListView.builder(
        itemCount: roomsInBuilding.length,
        itemBuilder: (context, index){
          Room _room = roomsInBuilding[index];
          return RoomCard(_room);
        }
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

  Widget _buildLoadingWidget(){
    return Center(
      child: Container(
        height: 100,
        width: 100,
        child: CircularProgressIndicator(),
      ),
    );
  }

}