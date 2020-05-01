import 'dart:async';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_manager.dart';
import 'package:flutter/foundation.dart';

class DialogService {
  Function(DialogRequest) _showDialogListener;
  Function() _dismissDialogListener;
  List<Completer<DialogResponse>> _dialogCompleter;

  static final DialogService _dialogService = DialogService._internal();

  factory DialogService() {
    return _dialogService;
  }

  DialogService._internal(){
    _dialogCompleter = List();
  }

  void registerDialogListener(Function(DialogRequest) showDialogListener,
      Function dismissDialogListener) {
    _showDialogListener = showDialogListener;
    _dismissDialogListener = dismissDialogListener;
  }

  Future showDialog({
    @required DialogType type,
    @required String title,
    @required String description,
    String primaryButtonTitle = 'OK',
    String secondaryButtonTitle,
    bool dismissible = true
  }) {
    _dialogCompleter.add(Completer<DialogResponse>());
    _showDialogListener(DialogRequest(
        type: type,
        title: title,
        description: description,
        primaryButtonTitle: primaryButtonTitle,
        secondaryButtonTitle: secondaryButtonTitle,
        dismissible: dismissible
    ));
    return _dialogCompleter.last.future;
  }

  Future showLoadingDialog({
    @required String title
  }) {
    _dialogCompleter.add(Completer<DialogResponse>());
    _showDialogListener(DialogRequest(
      type: DialogType.Loading,
      title: title,
      description: null,
      primaryButtonTitle: null,
      secondaryButtonTitle: null,
    ));
    return _dialogCompleter.last.future;
  }
  Future showFullscreenLoadingDialog({
    @required String description
  }) {
    _dialogCompleter.add(Completer<DialogResponse>());
    _showDialogListener(DialogRequest(
      type: DialogType.FullScreenLoading,
      title: null,
      description: description,
      primaryButtonTitle: null,
    ));
    return _dialogCompleter.last.future;
  }

  void dialogComplete(DialogResponse response) {
    _dialogCompleter.last.complete(response);
    _dismissDialogListener();
    _dialogCompleter.removeLast();
  }

  void goBack() {
    _dismissDialogListener();
  }
}