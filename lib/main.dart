import 'package:InTheNou/RouteGenerator.dart';
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/start_up_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

DialogService service = DialogService();

Future<void> main() async {
//  enableFlutterDriverExtension(handler: TestHandler.dataHandler);
  WidgetsFlutterBinding.ensureInitialized();
  Utils.checkSharedPrefs();
  runApp(
    Phoenix(
      child: InTheNouApp(),
    ),
  );
}

class InTheNouApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntheNou',
      theme: ThemeData(
        primarySwatch: primaryColor,
        accentColor: secondaryColor,
        errorColor: errorColor,
        cardTheme: CardTheme(color: ThemeData.fallback().cardColor,
            clipBehavior: Clip.antiAlias,
            elevation: 1.0,
            margin: const EdgeInsets.all(4.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius))
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(
                "Oops, an error happend. \nPlease restart the application "
                    "or contact the Development Team.",
                style: Theme.of(context).textTheme.headline5,
              ),
              RaisedButton(
                child: Text("Restart"),
                onPressed: () => Phoenix.rebirth(context),
              )
            ],
          ),
        ),
      ),
    );
  }

}

