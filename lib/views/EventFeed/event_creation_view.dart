import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/event_creation_store.dart';
import 'package:InTheNou/views/EventFeed/tag_selection_widget.dart';
import 'package:InTheNou/views/EventFeed/website_alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;


class EventCreationView extends StatefulWidget {

  @override
  _EventCreationViewState createState() => new _EventCreationViewState();

}

class _EventCreationViewState extends State<EventCreationView>
  with flux.StoreWatcherMixin<EventCreationView>{

  final _formKey = GlobalKey<FormState>();
  final format = DateFormat("EEE d: hh:mm aaa");
  final DateTime _initialDaeTime = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day);
  EventCreationStore _creationStore;

  @override
  void initState() {
    _creationStore = listenToStore(eventCreationStoreToken);
  }

  bool _autoValidate = false;
  bool _autoValidateDates = false;
  bool _endDateEnable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EventCreationView"),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text(
              "SUBMIT"
            ),
            onPressed: (){
              if(_formKey.currentState.validate()
                  && _creationStore.selectedTags.length < 11
                  && _creationStore.selectedTags.length > 2){
                _formKey.currentState.save();
                submitEventAction();
                Navigator.of(context).pop();
              }
              else if (_creationStore.selectedTags.length >10
                  || _creationStore.selectedTags.length < 3){
                showTagWarning(context);
              }
              else{
                setState(() {
                  _autoValidate = true;
                });
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0,
                  left: 8.0, right: 8.0),
              child: Column(
                  children: <Widget>[
                    //
                    //Title
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Event Title",
                          border: OutlineInputBorder()),
                      autovalidate: _autoValidate,
                      autocorrect: true,
                      maxLines: 1,
                      maxLength: 50,
                      validator: (value) {
                        if (value.isEmpty){
                          return "Title must be provided";
                        }else if(value.length < 3){
                          return "Title is too short";
                        }
                        return null;
                      },
                      onSaved: (String title) => inputEventTitleAction(title),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    //
                    // Description
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder()),
                      autovalidate: _autoValidate,
                      maxLines: null,
                      maxLength: 400,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null){
                          return "Description must be provided";
                        }else if(value.length < 3){
                          return "Description is too short";
                        }
                        return null;
                      },
                      onSaved: (String description) =>
                          inputEventDescriptionAction(description),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    //
                    //Dates
                    DateTimeField(
                      format: format,
                      decoration: InputDecoration(
                          labelText: "Event Start Date",
                          border: OutlineInputBorder()),
                      autovalidate: _autoValidateDates,
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                            context: context,
                            firstDate: _initialDaeTime,
                            initialDate: _creationStore.startDateTime ??
                                DateTime.now(),
                            lastDate: DateTime.now()
                                .add(Duration(days: 60)));
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime:
                            TimeOfDay.fromDateTime(_creationStore
                                .startDateTime ?? DateTime.now()),
                          );
                          inputEventStartAction(DateTimeField.combine(date, time));
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                      onChanged: (value) {
                        _formKey.currentState.setState(() {
                          _autoValidateDates = true;
                          _endDateEnable = value != null;
                        });
                      },
                        validator: (value) => validateDates(value)
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    DateTimeField(
                      format: format,
                      enabled: _endDateEnable,
                      decoration: InputDecoration(
                          labelText: "Event End Date",
                          border: OutlineInputBorder()),
                      autovalidate: _autoValidateDates,
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                            context: context,
                            firstDate: _initialDaeTime,
                            initialDate: _creationStore.endDateTime
                                ?? DateTime.now(),
                            lastDate: DateTime.now()
                                .add(Duration(days: 60)));
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime:
                            TimeOfDay.fromDateTime(_creationStore.endDateTime
                            ?? DateTime.now()),
                          );
                          inputEventEndAction(DateTimeField.combine(date, time));
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                      onChanged: (value) {
                        _formKey.currentState.setState(() {
                          _autoValidateDates = true;
                        });
                      },
                      validator: (value) => validateDates(value)
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 16.0)),
                    //
                    // Websites
                    Row(
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.only(left: 8.0)),
                        Expanded(
                          child: Text("Websites",
                          style: Theme.of(context).textTheme.subtitle1),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 150.0)),
                        IconButton(
                            icon: Icon(Icons.add),
                            onPressed: (){
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return WebsiteAlertDialog();
                                  });
                            },
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: kElevationToShadow[2]
                      ),
                      child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _creationStore.websites.length,
                          itemBuilder: (BuildContext context, int index) {
                            Website website = _creationStore.websites[index];
                            return Material(
                              color: Theme.of(context).cardColor,
                              child: InkWell(
                                onTap: (){},
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0,
                                      bottom: 8.0, left: 16.0, right: 16.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text (
                                              website.description,
                                              style: Theme.of(context).textTheme.subtitle2,
                                            ),
                                            Text (
                                              website.URL,
                                              style: Theme.of(context).textTheme.bodyText2,
                                            )
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: (){
                                          removeWebsiteAction(website);
                                        },
                                        icon: Icon(Icons.delete),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index)
                          => Divider()
                      ),
                    ),
                    //
                    const Padding(padding: EdgeInsets.only(bottom: 16.0)),
                    //
                    //Tags
                    Row(
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.only(left: 8.0)),
                        Expanded(
                          child: Text(
                              "Select 3 to 10 Tags:",
                              style:Theme.of(context).textTheme.subtitle1,
                          ),
                        )
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    TagSelectionWidget(),
                    //
                  ]
              ),
            )
        ),
      )
    );
  }


  String validateDates(value){
    if(value == null){
      return "Insert Date";
    }
    if(_creationStore.endDateTime != null){
      if(_creationStore.endDateTime.difference
        (_creationStore.startDateTime).inDays > 7){
        return "Event Duration too long";
      }
      if(_creationStore.endDateTime.difference
        (_creationStore.startDateTime).inMinutes < 10){
        return "Event Duration too short";
      }
      if (_creationStore.startDateTime.isAfter
        (_creationStore.endDateTime)){
        return "Event Start After Event End";
      }
    }
    return null;
  }

  void showTagWarning(BuildContext context){
      showDialog(context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text("Incorrect number of Tags"),
          content: Text(
            "Please choose between 3 to 10 Tags that best describe the Event "
                "before Sumbitting."
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text(
                "CONFIRM"
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      }
    );
  }

}
