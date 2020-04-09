import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/InformoationBase/room_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


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
    if(_infoBaseStore.getError(InfoBaseSearchType.Floor) !=null){
      showErrorDialog(_infoBaseStore.getError(InfoBaseSearchType.Floor));
    }
    if(_infoBaseStore.roomsInBuilding == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_infoBaseStore.selectedFloor.floorName + " Floor"),
        ),
        body: Center(
          child: Container(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_infoBaseStore.selectedFloor.floorName + " Floor"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: _infoBaseStore.roomsInBuilding.length,
                itemBuilder: (context, index){
                  Room _room = _infoBaseStore.roomsInBuilding[index];
                  return RoomCard(_room);
                }),
          )
        ],
      )
    );
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
                clearInfoBaseErrorAction(InfoBaseSearchType.Floor);
              },
            ),
          ],
        ),
      );
    });
  }
}