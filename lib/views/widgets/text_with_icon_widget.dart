import 'package:flutter/material.dart';

class TextWithIcon extends StatelessWidget{
  String _text;
  Widget _icon;

  TextWithIcon(this._text, this._icon);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(padding: EdgeInsets.only(bottom: 4.0)),
        Row(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(left: 8.0)),
            _icon,
            const Padding(padding: EdgeInsets.only(left: 16.0)),
            Text(
              _text,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.only(bottom: 4.0)),
      ],
    );
  }
}
