import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:flutter/material.dart';

/// The widget used to show [Room] results
///
/// {@category Widget}
class RoomCard extends StatelessWidget {

  final Room _room;
  RoomCard(this._room): super(key: ValueKey(_room));

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
            onTap: () {
              selectRoomAction(_room);
              Navigator.of(context).pushNamed("/infobase/room");
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _room.building,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ?
                        Theme.of(context).primaryColorLight :
                        Theme.of(context).primaryColor,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8.0)),
                  Text(
                    _room.code,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 16.0)),
                  Text(
                    _room.description,
                    style: Theme.of(context).textTheme.subtitle1,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  )
                ],
              ),
            )
        )
    );
  }

}