import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/phone_number.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/views/widgets/link_with_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_infoBaseStore.detailService.name),
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
                                  _infoBaseStore.detailService.name,
                                  style: Theme.of(context).textTheme.headline5,
                                  softWrap: true,
                                ),
                                const Padding(padding: EdgeInsets.only(bottom:
                                8.0)),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8.0, 4.0,
                                      8.0, 4.0),
                                  child: Text(
                                    _infoBaseStore.detailService
                                        .description,
                                    style: Theme.of(context).textTheme.subtitle1,
                                    softWrap: true,
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
                                              text: "Room: "
                                          ),
                                          TextSpan(
                                              text: _infoBaseStore.detailService.roomCode,
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
                  ),
                  //
                  // Contact info
                  Card(
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
                                    itemCount: _infoBaseStore.detailService.websites.length,
                                    itemBuilder: (context, index){
                                      Website _website = _infoBaseStore
                                          .detailService.websites[index];
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
                                itemCount: _infoBaseStore
                                    .detailService.numbers.length,
                                itemBuilder: (context, index){
                                  PhoneNumber _phone = _infoBaseStore
                                      .detailService.numbers[index];
                                  return LinkWithIconWidget(
                                      _phone.number,
                                      "tel:${_phone.number}",
                                      selectPhoneIcon(_phone.type)
                                  );
                                })
                        )
                      ],
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
                          title: Text(_infoBaseStore.detailService.schedule,
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

  Widget selectPhoneIcon(PhoneType type){
    switch (type){
      case PhoneType.E:
        return Icon(Icons.phone);
        break;
      case PhoneType.F:
        return ImageIcon(
          AssetImage("lib/assets/deskphone.png"),
        );
        break;
      case PhoneType.L:
        return ImageIcon(
          AssetImage("lib/assets/phone-classic.png"),
        );
        break;
      case PhoneType.M:
        return Icon(Icons.smartphone);
        break;
      default:
        return Icon(Icons.phone);
        break;
    }
  }
}