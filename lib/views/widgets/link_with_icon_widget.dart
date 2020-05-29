import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility Widget to show a clickable link
///
/// {@category Widget}
class LinkWithIconWidget extends StatelessWidget{
  final String _description;
  final String _URL;
  final Widget _icon;

  LinkWithIconWidget(this._description, this._URL, this._icon);

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      title: RichText(
        text: TextSpan(
          text: _description,
          style: Theme.of(context).textTheme.subtitle1.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline),
          recognizer: new TapGestureRecognizer()
            ..onTap = () { _launchURL(_URL);
            },
        ),
      ),
      leading: _icon,
      dense: true,
    );
  }
  _launchURL(String URL) async {
    if (await canLaunch(URL)) {
      await launch(URL);
    } else {
      throw 'Could not launch $URL';
    }
  }
}