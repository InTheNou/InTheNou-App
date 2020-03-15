import 'package:flutter/material.dart';

class InfoBaseSearchView extends StatefulWidget {

  @override
  _InfoBaseSearchViewState createState() => new _InfoBaseSearchViewState();

}

class _InfoBaseSearchViewState extends State<InfoBaseSearchView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("InfoBaseSearchView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("InfoBaseSearchView", style: Theme.of(context).textTheme.headline4,),
          ],
        ),
      ),
    );
  }
}