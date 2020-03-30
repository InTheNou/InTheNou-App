import 'package:InTheNou/RouteGenerator.dart';
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/start_up_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
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
    );
  }


}

