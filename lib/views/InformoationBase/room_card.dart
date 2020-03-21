import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {

  final Room _room;
  RoomCard(this._room);

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed("/infobase/room");
              selectRoomAction(_room);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _room.building,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Theme.of(context).accentColor
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 4.0)),
                  Text(
                    _room.code,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8.0)),
                  Text(
                    _room.description,
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                ],
              ),
            )
        )
    );
  }

}