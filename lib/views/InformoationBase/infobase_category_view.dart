import 'package:InTheNou/assets/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

const String INFORMATION_BASE = "Information Base";

/// The view for showing the Category selection of the Information Base
///
/// Currently the categories are Buildings, Rooms and Services. But this can
/// be expanded in the future to accommodate other times of information to be
/// made available to the user.
///
/// {@category View}
class InfoBaseCategoryView extends StatefulWidget{

  InfoBaseCategoryView({Key key}) : super(key: key);

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
            color: Theme.of(context).cardColor,
            textColor: Theme.of(context).brightness == Brightness.light ?
            Theme.of(context).primaryColor : Colors.white,
            child: Text("Buildings",
                style: Theme.of(context).textTheme.headline5),
            padding: EdgeInsets.all(16.0),
            onPressed: () => Navigator.of(context).pushNamed(
                '/infobase/search', arguments: InfoBaseType.Building),
          ),
          RaisedButton(
            color: Theme.of(context).cardColor,
            textColor: Theme.of(context).brightness == Brightness.light ?
            Theme.of(context).primaryColor : Colors.white,
            child: Text("Rooms",
                style: Theme.of(context).textTheme.headline5),
            padding: EdgeInsets.all(16.0),
            onPressed: () => Navigator.of(context).pushNamed
              ("/infobase/search", arguments: InfoBaseType.Room),
          ),
          RaisedButton(
            color: Theme.of(context).cardColor,
            textColor: Theme.of(context).brightness == Brightness.light ?
              Theme.of(context).primaryColor : Colors.white,
            child: Text("Services",
                style: Theme.of(context).textTheme.headline5),
            padding: EdgeInsets.all(16.0),
            onPressed: () => Navigator.of(context).pushNamed
              ("/infobase/search", arguments: InfoBaseType.Service),
          ),
        ],
      )
    );
  }


}
