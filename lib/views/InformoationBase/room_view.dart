import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/widgets/link_with_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class RoomView extends StatefulWidget {

  @override
  _RoomViewState createState() => new _RoomViewState();

}

class _RoomViewState extends State<RoomView>
  with flux.StoreWatcherMixin<RoomView>{

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
        title: Text(_infoBaseStore.detailRoom.code),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 16.0)),
            Expanded(
              child: Column(
                children: <Widget>[
                  //
                  // Basic info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _infoBaseStore.detailRoom.description,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                            child: RichText(
                              text: TextSpan(
                                  style: Theme.of(context).textTheme.subtitle1,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "Building: "
                                    ),
                                    TextSpan(
                                        text: _infoBaseStore.detailRoom.building,
                                        style: Theme.of(context).textTheme
                                            .subtitle1.copyWith(fontWeight:
                                        FontWeight.bold)
                                    )
                                  ]
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                            child: RichText(
                              text: TextSpan(
                                  style: Theme.of(context).textTheme.subtitle1,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "Floor: "
                                    ),
                                    TextSpan(
                                        text: _infoBaseStore.detailRoom
                                            .floor.toString(),
                                        style: Theme.of(context).textTheme
                                            .subtitle1.copyWith(fontWeight:
                                        FontWeight.bold)
                                    )
                                  ]
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                            child: RichText(
                              text: TextSpan(
                                  style: Theme.of(context).textTheme
                                      .subtitle1,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "Occupancy: "
                                    ),
                                    TextSpan(
                                        text: _infoBaseStore.detailRoom
                                            .occupancy.toString(),
                                        style: Theme.of(context).textTheme
                                            .subtitle1.copyWith(fontWeight:
                                        FontWeight.bold)
                                    )
                                  ]
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: LinkWithIconWidget(
                                    "location",
                                    Utils.buildGoogleMapsLink(_infoBaseStore
                                        .detailRoom.coordinates),
                                    Icon(Icons.location_on)
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                  //
                  // Contact info
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Contact Information",
                              style: Theme.of(context).textTheme.subtitle2.copyWith(
                                  fontWeight: FontWeight.w300
                              ),
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                          // Adding the mailto: makes it a clickable email link
                          child: LinkWithIconWidget(
                              _infoBaseStore.detailRoom.custodian,
                              "mailto:<${_infoBaseStore.detailRoom.custodian}>",
                              Icon(Icons.mail)
                          ),
                        )
                      ],
                    ),
                  ),
                  //
                  //Services
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Services",
                              style: Theme.of(context).textTheme.subtitle2.copyWith(
                                  fontWeight: FontWeight.w300
                              ),
                            )
                        ),
                        ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _infoBaseStore.servicesInRoom.length,
                            itemBuilder: (context, index){
                              Service _service = _infoBaseStore.servicesInRoom[index];
                              return  InkWell(
                                onTap: () => {
                                  selectServiceAction(_service),
                                  Navigator.of(context).pushNamed
                                    ("/infobase/service"),
                                },
                                child: ListTile(
                                  title: Text(_service.name,
                                      style: Theme.of(context).textTheme.subtitle1),
                                  subtitle: Text(_service.description),
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