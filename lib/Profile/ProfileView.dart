import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

const String PROFILE = "Profile";

class ProfileView extends StatefulWidget{
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State{
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(PROFILE),
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(PROFILE,style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
  
}