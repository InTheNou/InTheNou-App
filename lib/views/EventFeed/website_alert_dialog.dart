import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/event_creation_store.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

class WebsiteAlertDialog extends StatefulWidget {

  @override
  _WebsiteAlertDialogState createState() => new _WebsiteAlertDialogState();

}

class _WebsiteAlertDialogState extends State<WebsiteAlertDialog> {
  String _name;
  String _URL;
  bool _validate = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add a Website"),
      content: Form (
        key: _formKey,
        child: Column (
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField (
              decoration: InputDecoration(
                  labelText: "Link Name",
                  border: OutlineInputBorder()),
              autovalidate: _validate,
              autocorrect: true,
              maxLines: null,
              maxLength: 50,
              keyboardType: TextInputType.text,
              validator: (String value) {
                if (value.isEmpty){
                  return "Name is required.";
                }else if(value.length < 3){
                  return "Name is too short";
                }
                return null;
              },
              onSaved: (String value){
                _name = value;
              },
            ),
            const Padding(padding: EdgeInsets.only(top: 8.0)),
            TextFormField (
              decoration: InputDecoration(
                  labelText: "Link URL",
                  border: OutlineInputBorder()),
              autovalidate: _validate,
              maxLines: null,
              maxLength: 400,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value.isEmpty){
                  return "URL is required";
                }else if(!Uri.parse(value).isAbsolute || !isURL(value)){
                  return "Invalid URL";
                }
                return null;
              },
              onSaved: (value){
                _URL = value;
              },
            )
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: Text(
              "CANCEL"
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: 16.0)),
        RaisedButton(
          onPressed: (){
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              addWebsiteAction(new Website(_URL, _name));
              Navigator.of(context).pop();
            }
            else {
              setState(() {
                _validate = true;
              });
            }
          },
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          child: Text(
              "SUBMIT"
          ),
        )
      ],
    );
  }
}