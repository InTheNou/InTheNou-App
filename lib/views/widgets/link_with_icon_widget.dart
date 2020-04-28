import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkWithIconWidget extends StatelessWidget{
  final String _description;
  final String _URL;
  final Widget _icon;

  LinkWithIconWidget(this._description, this._URL, this._icon);

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      title: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: _description,
          style: new TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              fontSize: Theme.of(context).textTheme.subtitle1.fontSize),
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