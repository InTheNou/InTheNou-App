import 'package:flutter/material.dart';

/// Utility Widget to show text with an icon
///
/// {@category Widget}
class TextWithIcon extends StatelessWidget{
  final String _text;
  final Widget _icon;

  TextWithIcon(this._text, this._icon);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_text, style: Theme.of(context).textTheme.subtitle1),
      leading: _icon,
      dense: true,
    );
  }
}
