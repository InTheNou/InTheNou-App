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
      case DialogType.Alert:
        _showAlert(request);
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
            title: Text(request.title),
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