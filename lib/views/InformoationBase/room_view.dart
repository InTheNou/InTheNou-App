import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/widgets/error_body_widget.dart';
import 'package:InTheNou/views/widgets/link_with_icon_widget.dart';
import 'package:InTheNou/views/widgets/loading_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

/// The view for showing detailed information about a selected [Room]
///
/// {@category View}
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
        title: Text(_infoBaseStore.selectedRoom.code),
      ),
      body: FutureBuilder(
        future: _infoBaseStore.detailRoom,
        builder: (BuildContext context, AsyncSnapshot<dynamic> detailRoom) {
          if(detailRoom.hasData){
            return _buildBody(detailRoom.data);
          }
          else if(detailRoom.hasError){
            return ErrorBodyWidget(detailRoom.error);
          }
          return LoadingBodyWidget();
        },
      ),
    );
  }

  Widget _buildBody(Room detailRoom) {
    return SingleChildScrollView(
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
                          detailRoom.description,
                          style: Theme.of(context).textTheme.headline5.copyWith(
                              fontWeight: FontWeight.bold),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 16.0)),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle1,
                              children: <TextSpan>[
                                TextSpan(text: "Building: "),
                                TextSpan(
                                    text: detailRoom.building,
                                    style: Theme.of(context).textTheme
                                        .subtitle1.copyWith(
                                        fontWeight: FontWeight.bold)
                                )
                              ]
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle1,
                              children: <TextSpan>[
                                TextSpan(text: "Floor: "),
                                TextSpan(
                                    text: detailRoom.floor.toString(),
                                    style: Theme.of(context).textTheme
                                        .subtitle1.copyWith(
                                        fontWeight: FontWeight.bold)
                                )
                              ]
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle1,
                              children: <TextSpan>[
                                TextSpan(text: "Department: "),
                                TextSpan(
                                    text: detailRoom.department,
                                    style: Theme.of(context).textTheme
                                        .subtitle1.copyWith(
                                        fontWeight: FontWeight.bold)
                                )
                              ]
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle1,
                              children: <TextSpan>[
                                TextSpan(text: "Occupancy: "),
                                TextSpan(
                                    text: detailRoom.occupancy.toString(),
                                    style: Theme.of(context).textTheme
                                        .subtitle1.copyWith(
                                        fontWeight: FontWeight.bold)
                                )
                              ]
                          ),
                        ),
                        LinkWithIconWidget(
                            "location",
                            Utils.buildGoogleMapsLink(
                                detailRoom.coordinates),
                            Icon(Icons.location_on)
                        ),
                      ],
                    ),
                  )
                ),
                //
                // Contact info
                Visibility(
                  visible: detailRoom.custodian != null && detailRoom
                      .custodian.trim().isNotEmpty,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Contact Information",
                              style: Theme.of(context).textTheme.subtitle2
                                  .copyWith(fontWeight: FontWeight.w300),
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                          // Adding the mailto: makes it a clickable email link
                          child: LinkWithIconWidget(
                              detailRoom.custodian,
                              "mailto:<${detailRoom.custodian}>",
                              Icon(Icons.mail)
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                //
                //Services
                Visibility(
                  visible: detailRoom.services.length > 0,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Services",
                              style: Theme.of(context).textTheme.subtitle2
                                  .copyWith(fontWeight: FontWeight.w300),
                            )
                        ),
                        ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: detailRoom.services.length,
                            itemBuilder: (context, index) {
                              Service _service = detailRoom.services[index];
                              return InkWell(
                                onTap: () {
                                  selectServiceAction(_service);
                                  Navigator.of(context).pushNamed
                                    ("/infobase/service");
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
                            separatorBuilder: (context, index) => Divider()
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}