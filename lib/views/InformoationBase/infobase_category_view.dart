import 'package:InTheNou/assets/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

const String INFORMATION_BASE = "Inforamtion Base";

class InfoBaseCategoryView extends StatefulWidget{

  InfoBaseCategoryView({Key key}) : super(key: PageStorageKey(key));

  @override
  InformationBaseState createState() => InformationBaseState();
}

class InformationBaseState extends State<InfoBaseCategoryView> with flux.StoreWatcherMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(INFORMATION_BASE),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        crossAxisCount: 2,
        children: <Widget>[
          RaisedButton(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(16.0),
            child: Text("Buildings",
                style: Theme.of(context).textTheme.headline5.copyWith(
                    color: Theme.of(context).canvasColor
                )),
            onPressed: () => Navigator.of(context).pushNamed(
                '/infobase/search', arguments: InfoBaseSearchType.Building),
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).canvasColor,
            child: Text("Rooms",
                style: Theme.of(context).textTheme.headline5.copyWith(
                    color: Theme.of(context).canvasColor
                )),
            padding: EdgeInsets.all(16.0),
            onPressed: () => Navigator.of(context).pushNamed
              ("/infobase/search", arguments: InfoBaseSearchType.Room),
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).canvasColor,
            child: Text("Services",
                style: Theme.of(context).textTheme.headline5.copyWith(
                    color: Theme.of(context).canvasColor
                )),
            padding: EdgeInsets.all(16.0),
            onPressed: () => Navigator.of(context).pushNamed
              ("/infobase/search", arguments: InfoBaseSearchType.Service),
          ),
        ],
      )
    );
  }


}
