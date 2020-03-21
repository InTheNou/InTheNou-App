import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkWithIconWidget extends StatelessWidget{
  String _description;
  String _URL;
  IconData _icon;

  LinkWithIconWidget(this._description, this._URL, this._icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Row(
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(left: 8.0)),
          Icon(
              _icon),
          const Padding(padding: EdgeInsets.only(left: 16.0)),
          Expanded(
            flex: 1,
            child: RichText(
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
            )
          ),
        ],
      ),
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