import 'package:flutter/material.dart';

/// Utility Widget to show text with an icon and a bold part of the text at the
/// end
///
/// {@category Widget}
class MultiTextWithIcon extends StatelessWidget{
  final String _boldText;
  final String _normalText;
  final IconData _icon;

  MultiTextWithIcon(this._normalText, this._boldText, this._icon);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Padding(padding: EdgeInsets.only(left: 16.0)),
        Icon(_icon),
        const Padding(padding: EdgeInsets.only(left: 32.0)),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.subtitle1,
            children: <TextSpan>[
              TextSpan(text: _normalText),
              TextSpan(text: "\t\t\t"),
              TextSpan(text: _boldText, style: TextStyle(
                  fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }
}