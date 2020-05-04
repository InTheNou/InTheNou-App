import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/phone_number.dart';
import 'package:InTheNou/models/service.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/widgets/link_with_icon_widget.dart';
import 'package:InTheNou/views/widgets/text_with_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

/// The view for showing detailed information about a selected [Floor]
///
/// {@category View}
class ServiceView extends StatefulWidget {

  @override
  _ServiceViewState createState() => new _ServiceViewState();

}

class _ServiceViewState extends State<ServiceView>
    with flux.StoreWatcherMixin<ServiceView>{

  InfoBaseStore _infoBaseStore;

  @override
  void initState() {
    super.initState();
    _infoBaseStore = listenToStore(InfoBaseStore.infoBaseToken);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _infoBaseStore.detailService,
      builder: (BuildContext context, AsyncSnapshot<dynamic> detailService) {
        if(detailService.hasData){
          return _buildBody(detailService.data);
        }
        else if(detailService.hasError){
          return _buildErrorWidget(detailService.error.toString());
        }
        return _buildLoadingWidget();
      },
    );
  }

  Widget _buildBody(Service detailService){
    return Scaffold(
      appBar: AppBar(
        title: Text(detailService.name),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 16.0)),
            Expanded(
              child: Column(
                children: <Widget>[
                  //
                  // Basic Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  detailService.name,
                                  style: Theme.of(context).textTheme.headline5.copyWith(
                                    fontWeight: FontWeight.bold
                                  ),
                                  softWrap: true,
                                ),
                                const Padding(padding: EdgeInsets.only(bottom:
                                16.0)),
                                RichText(
                                  text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: "Room: ",
                                          style: Theme.of(context)
                                              .textTheme.subtitle1,
                                        ),
                                        TextSpan(
                                            text: detailService.roomCode,
                                            style: Theme.of(context).textTheme
                                                .subtitle1.copyWith(fontWeight:
                                            FontWeight.bold)
                                        )
                                      ]
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.only(bottom:
                                8.0)),
                                Text(
                                  detailService.description,
                                  style: Theme.of(context).textTheme.subtitle1,
                                  softWrap: true,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  //
                  // Contact info
                  Visibility(
                    visible: detailService.websites.length>0,
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 4.0,
                                  8.0, 4.0),
                              child: Text(
                                "Contact Information",
                                style: Theme.of(context).textTheme.subtitle2.copyWith(
                                    fontWeight: FontWeight.w300
                                ),
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 4.0,
                                8.0, 2.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: detailService.websites.length,
                                      itemBuilder: (context, index){
                                        Website _website =
                                            detailService.websites[index];
                                        return LinkWithIconWidget(
                                            _website.description ?? _website.URL,
                                            _website.URL,
                                            Icon(Icons.language)
                                        );
                                      }),
                                )
                              ],
                            )
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 2.0,
                                  8.0, 4.0),
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: detailService.numbers.length,
                                  itemBuilder: (context, index){
                                    PhoneNumber _phone =
                                        detailService.numbers[index];
                                    return createPhoneEntry(_phone);
                                  })
                          )
                        ],
                      ),
                    ),
                  ),
                  //
                  //Schedule
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0,
                                left: 8.0, right: 8.0),
                            child: Text(
                              "Schedule:",
                              style: Theme.of(context).textTheme.subtitle2.copyWith(
                                  fontWeight: FontWeight.w300
                              ),
                            )
                        ),
                        ListTile(
                          title: Text(detailService.schedule,
                              style: Theme.of(context).textTheme.subtitle1),
                          leading: Icon(Icons.access_time),
                          dense: true,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
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
        ));
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

  Widget createPhoneEntry(PhoneNumber phoneNumber){
    switch (phoneNumber.type){
      case PhoneType.E:
        return LinkWithIconWidget(
            phoneNumber.number,
            "tel:${phoneNumber.number}",
            Icon(Icons.phone)
        );
        break;
      case PhoneType.F:
        return TextWithIcon(
          "Fax: "+ phoneNumber.number,
          ImageIcon(
              AssetImage("lib/assets/deskphone.png")),
        );
        break;
      case PhoneType.L:
        return LinkWithIconWidget(
          phoneNumber.number,
          "tel:${phoneNumber.number}",
          ImageIcon(
              AssetImage("lib/assets/phone-classic.png")),
        );
        break;
      case PhoneType.M:
        return LinkWithIconWidget(
            phoneNumber.number,
            "tel:${phoneNumber.number}",
            Icon(Icons.smartphone)
        );
        break;
      default:
        return LinkWithIconWidget(
            phoneNumber.number,
            "tel:${phoneNumber.number}",
            Icon(Icons.phone)
        );
        break;
    }
  }

}