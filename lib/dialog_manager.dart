import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:flutter/material.dart';

/// Class for that wraps root widget views so that Stores can show dialogs
///
/// This widget only needs to wrap around root views, not all views. As long
/// as a view that has this is still in context, the dialogs can be shown.
class DialogManager extends StatefulWidget {
  final Widget child;

  DialogManager({Key key, this.child}) : super(key: key);

  _DialogManagerState createState() => _DialogManagerState();

}

class _DialogManagerState extends State<DialogManager> {
  DialogService _dialogService;

  @override
  void initState() {
    _dialogService = DialogService();
    _dialogService.registerDialogListener(_showDialog, _dismissDialog);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// The method that gets called whenever a Dialog is going to be shown.
  ///
  /// The parameter [request] contains all the information needed to
  /// distinguish which type of dialog to show and the information to show.
  void _showDialog(DialogRequest request) {
    switch(request.type){
      case DialogType.Loading:
        _showLoading(request);
        break;
      case DialogType.FullScreenLoading:
        _showFullScreenLoading(request);
        break;
      case DialogType.Alert:
        _showAlert(request);
        break;
      case DialogType.ImportantAlert:
        _showImportantAlert(request);
        break;
      case DialogType.Error:
        _showErrorDialog(request);
        break;
    }
  }

  /// Utility method so that Stores can pop the current context without
  /// actually having the context.
  void _dismissDialog(){
    Navigator.of(context).pop();
  }

  /// Utility method to show a Dialog with a loading bar that is not dismissible
  void _showLoading(DialogRequest request){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(request.title),
            content: Container(
              child: CircularProgressIndicator(),
              alignment: AlignmentDirectional.center,
              width: 100,
              height: 100,
            )
          ),
        );
      },
    );
  }

  /// Utility method to show an Error Dialog.
  ///
  /// The parameter [request] can define if it can be dismissible
  void _showErrorDialog(DialogRequest request){
    showDialog(
      context: context,
      barrierDismissible: request.dismissible,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => request.dismissible,
          child: AlertDialog(
            title: Text("Error: "+request.title),
            content: Text(request.description),
            actions: <Widget>[
              FlatButton(
                child: Text(request.primaryButtonTitle),
                onPressed: () {
                  _dialogService.dialogComplete(DialogResponse(result: true));
                },
              )
            ],
          ),
        );
      },
    );
  }

  /// Utility method to show an Alert Dialog.
  ///
  /// The parameter [request] can define if it can be dismissible
  void _showAlert(DialogRequest request){
    showDialog(
      context: context,
      barrierDismissible: request.dismissible,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => request.dismissible,
          child: AlertDialog(
            title: Text(request.title),
            content: Text(request.description),
            actions: <Widget>[
              Visibility(
                visible: request.secondaryButtonTitle != null,
                child: FlatButton(
                  child: Text(request.secondaryButtonTitle ?? "CANCEL"),
                  onPressed: () {
                    _dialogService.dialogComplete(DialogResponse(result: false));
                  },
                ),
              ),
              FlatButton(
                child: Text(request.primaryButtonTitle),
                onPressed: () {
                  _dialogService.dialogComplete(DialogResponse(result: true));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Utility method to show an Important Alert Dialog.
  ///
  /// The parameter [request] can define if it can be dismissible. The
  /// secondary button will say "CANCEL" by default if not provided one.
  void _showImportantAlert(DialogRequest request){
    showDialog(
      context: context,
      barrierDismissible: request.dismissible,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => request.dismissible,
          child: AlertDialog(
            title: Text(request.title),
            content: Text(request.description),
            actions: <Widget>[
              FlatButton(
                child: Text(request.secondaryButtonTitle ?? "CANCEL"),
                onPressed: () {
                  _dialogService.dialogComplete(DialogResponse(result: false));
                },
              ),
              Padding(padding: EdgeInsets.only(left: 8.0)),
              FlatButton(
                textColor: Theme.of(context).brightness == Brightness.dark ?
                  Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
                child: Text(request.primaryButtonTitle),
                onPressed: () =>
                    _dialogService.dialogComplete(DialogResponse(result: true))
              ),
            ],
          ),
        );
      },
    );
  }

  /// Utility method to show a Fullscreen Loading Dialog.
  ///
  /// This type of Dialog can't be dismissed and has no action buttons.
  void _showFullScreenLoading(DialogRequest request) {
    showGeneralDialog(
        context: context,
        barrierColor: Colors.black12.withOpacity(0.6),
        barrierDismissible: false,
        barrierLabel: "Loading",
        transitionDuration: Duration(milliseconds: 200),
        pageBuilder: (context, _, __) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Theme.of(context)
                              .accentColor),
                          strokeWidth: 8.0,
                        )
                    ),
                    const Padding(padding: EdgeInsets.all(16.0)),
                    Text(request.description,
                        style: Theme.of(context).textTheme.headline5
                            .copyWith(color: Theme.of(context).canvasColor)
                    )
                  ],
                )
            ),
          );
        }
    );
  }
}


/// Utility object for information about hwo to build the Dialog.
///
/// {@category Model}
class DialogRequest {

  final DialogType type;
  final String title;
  final String description;
  final String primaryButtonTitle;
  final String secondaryButtonTitle;
  final bool dismissible;

  DialogRequest({
    @required this.type,
    @required this.title,
    @required this.description,
    @required this.primaryButtonTitle,
    this.secondaryButtonTitle,
    this.dismissible
  });

}


/// Utility object for the result after closing a dialog.
///
/// {@category Model}
class DialogResponse {
  final dynamic result;

  DialogResponse({
    this.result,
  });

}