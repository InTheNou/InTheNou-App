import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/assets/utils.dart';
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
    _infoBaseStore = listenToStore(InfoBaseStore.infoBaseToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: _infoBaseStore.detailBuilding.image.isNotEmpty ?
              250.0 : 0,
              floating: false,
              pinned: true,
              title: Text(_infoBaseStore.detailBuilding.name,
                style: Theme.of(context).textTheme.headline6.copyWith(
                    color: Theme.of(context).canvasColor
                ),
                overflow: TextOverflow.ellipsis,
              ),
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  collapseMode: CollapseMode.none,
                  background: Container(
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.1,0.3,0.5],
                          colors: <Color>[
                            primaryColor.shade900, primaryColor.shade300,
                            Colors.transparent
                          ]
                      ),
                    ),
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      placeholder: "lib/assets/placeholder.png",
                      height: 120.0,
                      image: _infoBaseStore.detailBuilding.image,
                    ),
                  )
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(top: 4.0)),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 16.0,
                                8.0, 4.0),
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
                            padding: const EdgeInsets.fromLTRB(8.0, 4.0,
                                8.0, 4.0),
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
                            padding: const EdgeInsets.fromLTRB(8.0, 4.0,
                                8.0, 4.0),
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
                        padding: const EdgeInsets.all( 8.0),
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
                        padding: const EdgeInsets.all((0)),
                        itemCount: _infoBaseStore.detailBuilding.numFloors,
                        itemBuilder: (context, index){
                          Floor _floor = Utils.ordinalNumber(index+1);
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
          )
        )
      ),
    );
  }
}