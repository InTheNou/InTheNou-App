import 'package:flutter/material.dart';

class TextWithIcon extends StatelessWidget{
  final String _text;
  final Widget _icon;

  TextWithIcon(this._text, this._icon);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_text),
      leading: _icon,
      dense: true,
    );
  }
}
