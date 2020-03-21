import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:flutter/material.dart';

class ServicesCard extends StatelessWidget {

  final Service _service;
  ServicesCard(this._service);

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed("/infobase/room");
              selectServiceAction(_service);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0,
              left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _service.roomCode,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 4.0)),
                  Text(
                    _service.name,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8.0)),
                  Text(
                    _service.description,
                    style: Theme.of(context).textTheme.subtitle2,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            )
        )
    );;
  }

}