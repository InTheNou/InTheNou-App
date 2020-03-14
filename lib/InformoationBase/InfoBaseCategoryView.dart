import 'package:flutter/material.dart';
import "InfoBaseStore.dart";
import 'package:flutter_flux/flutter_flux.dart' as flux;

const String INFORMATION_BASE = "Inforamtion Base";

class InfoBaseCategoryView extends StatefulWidget{
  @override
  InformationBaseState createState() => InformationBaseState();
}

class InformationBaseState extends State<InfoBaseCategoryView> with flux.StoreWatcherMixin {
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
        title: Text(INFORMATION_BASE),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(INFORMATION_BASE,style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }


}
