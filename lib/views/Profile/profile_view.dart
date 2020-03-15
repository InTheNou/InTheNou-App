import 'package:flutter/material.dart';

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