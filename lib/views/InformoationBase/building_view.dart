import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/widgets/loading_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

/// The view for showing detailed information about a selected [Building]
///
/// {@category View}
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
    return FutureBuilder(
      future: _infoBaseStore.detailBuilding,
      builder: (BuildContext context, AsyncSnapshot<dynamic> detailBuilding) {
        if(detailBuilding.hasData){
          return _buildBody(detailBuilding.data);
        }
        else if(detailBuilding.hasError){
          return _buildErrorWidget(detailBuilding.error.toString());
        }
        return _buildLoadingWidget();
      },
    );
  }

  Widget _buildBody(Building detailBuilding){
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: detailBuilding.image != null ?
                250.0 : 0,
                floating: true,
                pinned: true,
                title: Text(detailBuilding.name,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Colors.white
                  ),
                  maxLines: 1,
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
                            stops: [0.1,0.35,0.4],
                            colors: <Color>[
                              Color.fromARGB(124, 0, 0, 0),
                              Color.fromARGB(77, 0, 0, 0),
                              Colors.transparent
                            ]
                        ),
                      ),
                      child: LoadingImage(
                        imageURL: detailBuilding.image,
                        width: double.infinity,
                        height: double.infinity,
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  detailBuilding.name,
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
                                              text: detailBuilding
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
                                              text: detailBuilding
                                                  .abbreviation,
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
                                              text: detailBuilding.type,
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
                            itemCount: detailBuilding.floors.length,
                            itemBuilder: (context, index){
                              Floor _floor = detailBuilding.floors[index];
                              return  InkWell(
                                onTap: () => {
                                  Navigator.of(context).pushNamed
                                    ("/infobase/floor"),
                                  selectFloorAction(
                                      MapEntry(detailBuilding, _floor)
                                  )
                                },
                                child: ListTile(
                                  title: Text(_floor.floorName,
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

  Widget _buildErrorWidget(String error) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Error"),
        ),
        body: Center(
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
        )
    );
  }

  Widget _buildLoadingWidget(){
    return Scaffold(
      appBar: AppBar(
        title: Text("Loading"),
      ),
      body: Center(
        child: Container(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}