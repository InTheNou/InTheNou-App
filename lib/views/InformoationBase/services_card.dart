import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:flutter/material.dart';

/// The widget used to show [Service] results
///
/// {@category Widget}
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
              selectServiceAction(_service);
              Navigator.of(context).pushNamed("/infobase/service");
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _service.roomCode,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ?
                          Theme.of(context).primaryColorLight :
                          Theme.of(context).primaryColor,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8.0)),
                  Text(
                    _service.name,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 16.0)),
                  Text(
                    _service.description,
                    style: Theme.of(context).textTheme.subtitle2,
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