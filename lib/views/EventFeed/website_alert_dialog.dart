import 'package:InTheNou/assets/validators.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/event_creation_store.dart';
import 'package:flutter/material.dart';


class WebsiteAlertDialog extends StatefulWidget {

  final List<Website> sites;

  WebsiteAlertDialog(this.sites);

  @override
  _WebsiteAlertDialogState createState() => new _WebsiteAlertDialogState();

}

class _WebsiteAlertDialogState extends State<WebsiteAlertDialog> {
  String _name;
  String _URL;
  bool _validate = false;
  final _formKey = GlobalKey<FormState>();
  DialogService _dialogService = DialogService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add a Website"),
      content: Form (
        key: _formKey,
        child: SingleChildScrollView(
          child: Column (
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField (
                decoration: InputDecoration(
                    labelText: "Link Description",
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark ?
                            Theme.of(context).primaryColorLight :
                            Theme.of(context).primaryColor,
                            width: 1.0))
                ),
                autovalidate: _validate,
                maxLines: null,
                maxLength: 50,
                keyboardType: TextInputType.text,
                validator: (String website) => Validators.validateWebsiteDescription(website),
                onSaved: (String value){
                  _name = value.trim();
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 8.0)),
              TextFormField (
                decoration: InputDecoration(
                    labelText: "Link URL",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark ?
                          Theme.of(context).primaryColorLight :
                          Theme.of(context).primaryColor,
                          width: 1.0))
                ),
                autovalidate: _validate,
                maxLines: null,
                maxLength: 400,
                keyboardType: TextInputType.text,
                validator: (link) => Validators.validateWebsiteLink(link),
                onSaved: (value){
                  _URL = value.trim();
                },
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("CANCEL"),
        ),
        const Padding(padding: EdgeInsets.only(left: 16.0)),
        FlatButton(
          onPressed: (){
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              if(Validators.validateDuplicateWebsite(widget.sites,
                  new Website(_URL, _name))){
                _dialogService.showDialog(
                    type: DialogType.Alert,
                    title: "DUplicate Website",
                    description: "You have already added $_URL to the "
                        "Event");
              } else {
                modifyWebsiteAction(MapEntry(true,
                    Website(_URL.trim(), _name.trim())));
                Navigator.of(context).pop();
              }
            }
            setState(() {
              _validate = true;
            });
          },
          child: Text("SUBMIT"),
        )
      ],
    );
  }
}