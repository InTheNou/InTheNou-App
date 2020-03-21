import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class BuildingView extends StatefulWidget {

  @override
  _BuildingViewState createState() => new _BuildingViewState();

}

class _BuildingViewState extends State<BuildingView>
  with flux.StoreWatcherMixin<BuildingView>{

  InfoBaseStore _infoBaseStore;

  @override
  void initState() {
    super.initState();
    _infoBaseStore = listenToStore(infoBaseToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_infoBaseStore.detailBuilding.name),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 16.0)),
            Expanded(
              child: Column(
                children: <Widget>[
                  Card(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _infoBaseStore.detailBuilding.name,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                              Padding(
                                padding: EdgeInsets.only(top: 4.0, bottom: 4.0,
                                    left: 8.0, right: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                      style: Theme.of(context).textTheme.subtitle1,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "Common name: "
                                        ),
                                        TextSpan(
                                            text: _infoBaseStore.detailBuilding
                                                .commonName,
                                            style: Theme.of(context).textTheme
                                                .subtitle1.copyWith(fontWeight:
                                            FontWeight.bold)
                                        )
                                      ]
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 4.0, bottom: 4.0,
                                    left: 8.0, right: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                      style: Theme.of(context).textTheme.subtitle1,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "Abbreviation: "
                                        ),
                                        TextSpan(
                                            text: _infoBaseStore.detailBuilding
                                                .commonName,
                                            style: Theme.of(context).textTheme
                                                .subtitle1.copyWith(fontWeight:
                                            FontWeight.bold)
                                        )
                                      ]
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 4.0, bottom: 4.0,
                                    left: 8.0, right: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                      style: Theme.of(context).textTheme
                                          .subtitle1,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "Type of Building: "
                                        ),
                                        TextSpan(
                                            text: _infoBaseStore.detailBuilding.type,
                                            style: Theme.of(context).textTheme
                                                .subtitle1.copyWith(fontWeight:
                                            FontWeight.bold)
                                        )
                                      ]
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0,
                            left: 8.0, right: 8.0),
                          child: Text(
                            "Floors",
                            style: Theme.of(context).textTheme.subtitle2.copyWith(
                                fontWeight: FontWeight.w300
                            ),
                          )
                        ),
                        ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _infoBaseStore.detailBuilding.numFloors,
                            itemBuilder: (context, index){
                              Floor _floor = ordinalNumber(index+1);
                              return  InkWell(
                                onTap: () => {
                                  Navigator.of(context).pushNamed
                                    ("/infobase/floor"),
                                  selectFloorAction(
                                    MapEntry(_infoBaseStore
                                        .detailBuilding, _floor.floorNumber)
                                  )
                                },
                                child: ListTile(
                                  title: Text("${_floor.floorName} Floor",
                                    style: Theme.of(context).textTheme.subtitle1),
                                  trailing: Icon(Icons.navigate_next),
                                  dense: true,
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) => Divider()
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}