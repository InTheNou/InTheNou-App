import 'package:InTheNou/RouteGenerator.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/start_up_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  checkSharedPrefs();
  runApp(InTheNouApp());
}

class InTheNouApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntheNou',
      theme: ThemeData(
          primarySwatch: primaryColor,
          accentColor: secondaryColor
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
      home: StartUpView(),
    );
  }


}

