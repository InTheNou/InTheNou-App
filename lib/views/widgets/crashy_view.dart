import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CrashyView extends StatelessWidget {

  CrashyView();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Crashy'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new OutlineButton(
              child: new Text('Dart exception'),
              onPressed: () {
                throw new StateError('This is a Dart exception.');
              },
            ),
            new OutlineButton(
              child: new Text('async Dart exception'),
              onPressed: () async {
                foo() async {
                  throw new StateError('This is an async Dart exception.');
                }
                bar() async {
                  await foo();
                }
                await bar();
              },
            ),
            new OutlineButton(
              child: new Text('Java exception'),
              onPressed: () async {
                final channel = const MethodChannel('crashy-custom-channel');
                await channel.invokeMethod('blah');
              },
            ),
          ],
        ),
      ),
    );
  }

}