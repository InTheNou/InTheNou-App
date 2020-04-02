import 'dart:io';

import 'package:InTheNou/RouteGenerator.dart';
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/start_up_view.dart';
import 'package:InTheNou/test_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

Future<void> main() async {
//  enableFlutterDriverExtension(handler: TestHandler.dataHandler);
  WidgetsFlutterBinding.ensureInitialized();
  Utils.checkSharedPrefs();
  runApp(InTheNouApp());
}

class InTheNouApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntheNou',
      theme: ThemeData(
          primarySwatch: primaryColor,
          accentColor: secondaryColor,
          cardTheme: CardTheme(color: ThemeData.fallback().cardColor,
              clipBehavior: Clip.antiAlias,
              elevation: 1.0,
              margin: const EdgeInsets.all(4.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0))
          )
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
      home: StartUpView(),
      builder: (BuildContext context, Widget widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return buildError(context, errorDetails);
        };
        return widget;
      },
    );
  }

  Widget buildError(BuildContext context, FlutterErrorDetails error) {
    return Scaffold(
        body: Center(
          child: Text(
            error.toString(),
            style: Theme.of(context).textTheme.title,
          ),
        )
    );
  }

}

