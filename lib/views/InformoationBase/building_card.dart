import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/widgets/loading_image.dart';
import 'package:flutter/material.dart';

/// The widget used to show [Building] results
///
/// {@category Widget}
class BuildingCard extends StatelessWidget {

  final Building _building;
  BuildingCard(this._building);

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
          onTap: () {
            selectBuildingAction(_building);
            Navigator.of(context).pushNamed("/infobase/building");
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              LoadingImage(
                  imageURL: _building.image,
                  height: 120.0,
                  width: 150.0
              ),
              const Padding(padding: EdgeInsets.only(left: 16.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _building.name,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline6,
                      softWrap: true,
                    ),
                    const Padding(padding: EdgeInsets.only(top: 8.0)),
                    Text(
                      _building.commonName,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.subtitle1,
                      softWrap: true,
                    )
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

}