import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:flutter/material.dart';

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

  void _dismissDialog(){
    Navigator.of(context).pop();
  }

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
                visible: request.secondaryButtonTitle.isNotEmpty,
                child: FlatButton(
                  child: Text(request.secondaryButtonTitle),
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
              Visibility(
                visible: request.secondaryButtonTitle.isNotEmpty,
                child: FlatButton(
                  child: Text(request.secondaryButtonTitle),
                  onPressed: () {
                    _dialogService.dialogComplete(DialogResponse(result: false));
                  },
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 8.0)),
              RaisedButton(
                textColor: Theme.of(context).canvasColor,
                color: Theme.of(context).primaryColor,
                child:  Text(request.primaryButtonTitle),
                onPressed: () =>
                    _dialogService.dialogComplete(DialogResponse(result: true))
              ),
            ],
          ),
        );
      },
    );
  }

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


class DialogResponse {
  final dynamic result;

  DialogResponse({
    this.result,
  });

}