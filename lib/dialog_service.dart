import 'dart:async';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_manager.dart';
import 'package:flutter/foundation.dart';

class DialogService {
  Function(DialogRequest) _showDialogListener;
  Function() _dismissDialogListener;
  Completer<DialogResponse> _dialogCompleter;

  static final DialogService _dialogService = DialogService._internal();

  factory DialogService() {
    return _dialogService;
  }

  DialogService._internal();

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
    String secondaryButtonTitle = "",
    bool dismissible = true
  }) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListener(DialogRequest(
        type: type,
        title: title,
        description: description,
        primaryButtonTitle: primaryButtonTitle,
        secondaryButtonTitle: secondaryButtonTitle,
        dismissible: dismissible
    ));
    return _dialogCompleter.future;
  }

  Future showLoadingDialog({
    @required String title
  }) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListener(DialogRequest(
      type: DialogType.Loading,
      title: title,
      description: null,
      primaryButtonTitle: null,
      secondaryButtonTitle: null,
    ));
    return _dialogCompleter.future;
  }
  Future showFullscreenLoadingDialog({
    @required String description
  }) {
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListener(DialogRequest(
      type: DialogType.FullScreenLoading,
      title: null,
      description: description,
      primaryButtonTitle: null,
    ));
    return _dialogCompleter.future;
  }

  void dialogComplete(DialogResponse response) {
    _dialogCompleter.complete(response);
    _dismissDialogListener();
    _dialogCompleter = null;
  }
}