import 'package:flutter/material.dart';

class ServiceView extends StatefulWidget {

  @override
  _ServiceViewState createState() => new _ServiceViewState();

}

class _ServiceViewState extends State<ServiceView> {
  // TODO: add state variables and methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ServiceView"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("ServiceView", style: Theme.of(context).textTheme.headline4,),
          ],
        ),
      ),
    );
  }
}