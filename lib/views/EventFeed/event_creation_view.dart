import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/event_creation_store.dart';
import 'package:InTheNou/views/EventFeed/tag_selection_widget.dart';
import 'package:InTheNou/views/EventFeed/website_alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:validators/validators.dart';


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
  bool _autoValidate = false;
  bool _autoValidateDates = false;
  bool _endDateEnable = false;

  @override
  void initState() {
    _creationStore = listenToStore(EventCreationStore.eventCreationStoreToken);
    getBuildingsAction();
    getAllTagsAction();
    // In case the user had decided to save the draft and they had entered at
    // least the Start Date, this would enable the End Date picker
    _endDateEnable = _creationStore.startDateTime != null;
    super.initState();
  }

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
            onPressed: () => validateEventSubmit()
          )
        ],
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => showExitWarning(),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
            key: _formKey,
            onWillPop: () => showExitWarning(),
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
                      maxLines: 1,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      initialValue: _creationStore.title,
                      validator: (value) {
                        if (value.isEmpty){
                          return "Title must be provided";
                        } else if(value.trim().length < 3){
                          return "Invalid Title";
                        } else if(value.length < 3){
                          return "Title is too short";
                        }
                        return null;
                      },
                      onChanged: (String title) =>
                          inputEventTitleAction(title.trim()),
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
                      textInputAction: TextInputAction.done,
                      initialValue: _creationStore.description,
                      validator: (value) {
                        if (value.isEmpty){
                          return "Description must be provided";
                        } else if(value.trim().length < 3){
                          return "Invalid Description";
                        } else if(value.length < 3){
                          return "Description is too short";
                        }
                        return null;
                      },
                      onChanged: (String description) =>
                          inputEventDescriptionAction(description.trim()),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    //
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Event Image",
                          border: OutlineInputBorder()),
                      autovalidate: _autoValidate,
                      maxLines: 1,
                      maxLength: 400,
                      textInputAction: TextInputAction.next,
                      initialValue: _creationStore.title,
                      validator: (value) {
                        if(value.isNotEmpty &&
                            (!Uri.parse(value).isAbsolute || !isURL(value))){
                          return "Invalid Image";
                        }
                        return null;
                      },
                      onChanged: (String image) =>
                          inputEventImageAction(image),
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
                      initialValue: _creationStore.startDateTime,
                      autofocus: false,
                      focusNode: FocusNode(canRequestFocus: false),
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
                              inputEventDateAction(MapEntry(true,
                                  DateTimeField.combine(date, time)));
                              return DateTimeField.combine(date, time);
                            } else {
                          return currentValue;
                        }
                      },
                      validator: (value) => validateDates(value),
                      onChanged: (value) {
                        _formKey.currentState.setState(() {
                          _autoValidateDates = true;
                          _endDateEnable = value != null;
                        });
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    DateTimeField(
                      format: format,
                      enabled: _endDateEnable,
                      autofocus: false,
                      focusNode: FocusNode(canRequestFocus: false),
                      decoration: InputDecoration(
                          labelText: "Event End Date",
                          border: OutlineInputBorder()),
                      autovalidate: _autoValidateDates,
                      initialValue: _creationStore.endDateTime,
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
                          inputEventDateAction(MapEntry(false,
                              DateTimeField.combine(date, time)));
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                      validator: (value) => validateDates(value)
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 16.0)),
                    //
                    // Location
                    Row(
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.only(left: 8.0)),
                        Expanded(
                          child: Text("Location",
                              style: Theme.of(context).textTheme.subtitle1),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 8.0)),
                      ],
                    ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 8.0),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration.collapsed(
                              hintText: "Building"),
                          autovalidate: _autoValidate,
                          value: _creationStore.selectedBuilding,
                          items: _creationStore.buildings.map((Building building) {
                            return new DropdownMenuItem(
                              value: building,
                              child: new Text(building.name),
                            );
                          }).toList(),
                          onChanged: (value) => buildingSelectAction(value),
                          validator: (value) =>
                            value == null? "Please choose a Floor" : null,
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 8.0),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration.collapsed(
                              hintText: "Floor"),
                          autovalidate: _autoValidate,
                          value: _creationStore.selectedFloor,
                          items: _creationStore.floors.map((Floor floor) {
                            return new DropdownMenuItem(
                              value: floor,
                              child: new Text(floor.floorName),
                            );
                          }).toList(),
                          onChanged: (value) => floorSelectAction(value),
                          validator: (value) =>
                            value == null? "Please choose a Floor" : null,
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 8.0),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration.collapsed(
                              hintText: "Room"),
                          autovalidate: _autoValidate,
                          value: _creationStore.selectedRoom,
                          items: _creationStore.roomsInBuilding
                              .map((Room room) {
                            return new DropdownMenuItem(
                              value: room,
                              child: new Text(room.code),
                            );
                          }).toList(),
                          onChanged: (value) => roomSelectAction(value),
                          validator: (value) =>
                            value == null? "Please choose a Room" : null
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    //
                    // Websites
                    Row(
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.only(left: 8.0)),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Text("Websites",
                                  style: Theme.of(context).textTheme.subtitle1),
                              const Padding(padding: EdgeInsets.only(left: 8.0)),
                              Text("${_creationStore.websites.length}/3",
                                  style: Theme.of(context).textTheme
                                      .subtitle1.copyWith(
                                      fontWeight: FontWeight.w300
                                  )),
                            ],
                          )
                        ),
                        IconButton(
                            icon: Icon(Icons.add),
                            onPressed: (){
                              if(_creationStore.websites.length<10){
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => WebsiteAlertDialog()
                                );
                              }
                              else {
                                showWebsiteWarning();
                              }
                            },
                        ),
                      ],
                    ),
                    Card(
                      child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _creationStore.websites.length,
                          itemBuilder: (BuildContext context, int index) {
                            Website website = _creationStore.websites[index];
                            return InkWell(
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
                                      onPressed: () =>
                                          modifyWebsiteAction(MapEntry(false,website)),
                                      icon: Icon(Icons.delete),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index)
                            => Divider()
                      ),
                    ),
                    //
                    const Padding(padding: EdgeInsets.only(bottom: 24.0)),
                    //
                    //Tags
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.only(left: 8.0)),
                        Text(
                          "Select 3 to 10 Tags:",
                          style:Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                    TagSelectionWidget(),
                    //
                  ]
              ),
            )
        ),
      )
    );
  }

  void validateEventSubmit(){
    if(_formKey.currentState.validate()
        && _creationStore.selectedTags.length < 11
        && _creationStore.selectedTags.length > 2){
      showSubmitConfirmation().then((value) {
        if(value){
          submitEventAction();
          Navigator.of(context).pop();
        }
      });
    }
    else{
      if (_creationStore.selectedTags.length >10
          || _creationStore.selectedTags.length < 3){
        showTagWarning();
      }
      _formKey.currentState.save();
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Future<bool> showSubmitConfirmation(){
    return showDialog<bool>(context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text("Confirm Event"),
            content: Text(
                "Are you sure you want to sumbit this event? \nNo further "
                    "changes can be made to the event, eexcept for cancelling."
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text(
                    "CANCEL"
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Padding(padding: EdgeInsets.only(left: 16.0),),
              RaisedButton(
                textColor: Theme.of(context).canvasColor,
                color: Theme.of(context).primaryColor,
                child: Text(
                    "CONFIRM"
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              Padding(padding: EdgeInsets.only(left: 8.0),)
            ],
          );
        }
    );
  }

  showExitWarning(){
    showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('You have made some changes'),
          content: Text('Would you like to save your progress in the '
              'Event Creation temporerally?. \nIt will be discarted '
              'upon restart of the application.'),
          actions: [
            FlatButton(
              child: Text('Discard'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                discardEventAction();
              },
            ),
            Padding(padding: EdgeInsets.only(left: 16.0),),
            RaisedButton(
                textColor: Theme.of(context).canvasColor,
                color: Theme.of(context).primaryColor,
                child: Text('Save'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
            ),
            Padding(padding: EdgeInsets.only(left: 8.0),),
          ],
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
      if (_creationStore.startDateTime.isAfter
        (_creationStore.endDateTime)){
        return "Event Start After Event End";
      }
    }
    return null;
  }

  void showWebsiteWarning(){
    showDialog(context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Links limit"),
            content: Text(
                "You have reached the limit of 10 links associated with an "
                    "Event."
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

  void showTagWarning(){
      showDialog(context: context,
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
