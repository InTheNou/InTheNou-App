import 'dart:async';
import 'package:InTheNou/RouteGenerator.dart';
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_manager.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/start_up_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info/device_info.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

DialogService service = DialogService();

bool get isInDebugMode {
  // Assume you're in production mode.
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  return inDebugMode;
}

Future<Null> main() async {
//  enableFlutterDriverExtension(handler: TestHandler.dataHandler);
  WidgetsFlutterBinding.ensureInitialized();
  Utils.checkSharedPrefs();
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.
      _reportError(details.exception, details.stack);
//      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  // This is used to be able to report errors thrown by Dart
  runZoned(() {
    runApp(
      Phoenix(
        child: InTheNouApp(),
      ),
    );
  }, onError: (error, stackTrace){
    _reportError(error, stackTrace);
  });

}
final _format = DateFormat("EE, MMMM d, yyyy 'at' h:mma");

void _reportError(dynamic error, dynamic stackTrace) async{
  if (isInDebugMode) {
    print("Debug Caught: "+ error.toString());
    return;
  }
  print("Caught: "+ error.toString());
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  String stack = stackTrace.toString().replaceAll(RegExp(r'#\d{1,2} {1,10}'), "");
  String subject = "[App-Crash] ${_format.format(DateTime.now())}";
  String body =
      "\n" +
          "Device manufacturer: ${androidInfo.manufacturer} \n"+
          "Device brand: ${androidInfo.brand} \n" +
          "Device name: ${androidInfo.device} \n" +
          "Device model: ${androidInfo.model} \n" +
          "Android version: ${androidInfo.version.release} \n" +
          "Device ABIs: ${androidInfo.supportedAbis.toString()} \n\n" +
          "Error: ${error.toString()} \n" +
          "StackTrace: $stack"
  ;
  String url = "mailto:inthenouproject@gmail.com?subject=$subject&body=$body";
  print(url);
  launch(url);
}

class InTheNouApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
            brightness: brightness,
            primarySwatch: primaryColor,
            primaryColorLight: primaryColor[50],
            primaryColorDark: primaryColor[900],
            primaryColorBrightness: Brightness.dark,
            accentColor: secondaryColor,
            accentColorBrightness: Brightness.dark,
            errorColor: errorColor,
            toggleableActiveColor: brightness == Brightness.dark ?
              secondaryColor[900] : secondaryColor,
            canvasColor: brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[50],
            cardTheme: CardTheme(
                color: brightness == Brightness.dark ? Colors.grey[850] :
                Colors.white,
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
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: brightness == Brightness.dark ?
                  secondaryColor[900] : secondaryColor,
                foregroundColor: Colors.white
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: Colors.grey[850],
              actionTextColor: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              contentTextStyle: TextStyle(
                color: Colors.white
              )
            ),
            popupMenuTheme: PopupMenuThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            appBarTheme: AppBarTheme(
              brightness: Brightness.dark,
              color: brightness == Brightness.dark ?
              primaryColor[900] : primaryColor,
            )
        ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            title: 'IntheNou',
            theme: theme,
            onGenerateRoute: RouteGenerator.generateRoute,
            home: DialogManager(child: StartUpView()),
            builder: (context, widget) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                _reportError(errorDetails.exception, errorDetails.stack);
                return buildError(context, errorDetails);
              };
              return widget;
            },
          );
        }
    );
  }

  Widget buildError(BuildContext context, FlutterErrorDetails error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Oops, an error happend. \nPlease restart the application "
                    "or contact the Development Team.",
                style: Theme.of(context).textTheme.headline5,
              ),
              RaisedButton(
                textColor: Theme.of(context).canvasColor,
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

