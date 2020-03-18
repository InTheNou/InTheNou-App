import 'package:InTheNou/stores/event_creation_store.dart';
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
    _creationStore = listenToStore(EventCreationStoreToken);
  }

  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EventCreationView"),
      ),
      body: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0,
                  left: 16.0, right: 16.0),
              child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Event Name",
                          border: OutlineInputBorder()),
                      autovalidate: true,
                      autocorrect: true,
                      maxLines: 1,
                      maxLength: 50,
                      validator: (value) {
                        if (value.isEmpty){
                          return null;
                        }else if(value.length < 3){
                          return "Name is too short";
                        }
                        return null;
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    TextFormField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder()),
                      autovalidate: true,
                      maxLines: null,
                      maxLength: 400,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value.isEmpty){
                          return null;
                        }else if(value.length < 3){
                          return "Name is too short";
                        }
                        return null;
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    DateTimeField(
                      format: format,
                      decoration: InputDecoration(
                          labelText: "Event Start Date",
                          border: OutlineInputBorder()),
                      autovalidate: true,
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                            context: context,
                            firstDate: _initialDaeTime,
                            initialDate: _creationStore.startDateTime,
                            lastDate: DateTime.now()
                                .add(Duration(days: 60)));
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime:
                            TimeOfDay.fromDateTime(_creationStore
                                .startDateTime),
                          );
                          inputEventStartAction(DateTimeField.combine(date, time));
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                      validator: (value){
                        if(_creationStore.startDateTime.difference
                          (_creationStore.endDateTime).inDays > 7){
                          return "Event Duration too long";
                        }
                        if (_creationStore.startDateTime.isAfter
                          (_creationStore.endDateTime)){
                          return "Event Start After Event End";
                        }
                        return null;
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    DateTimeField(
                      format: format,
                      decoration: InputDecoration(
                          labelText: "Event End Date",
                          border: OutlineInputBorder()),
                      autovalidate: true,
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                            context: context,
                            firstDate: _initialDaeTime,
                            initialDate: _creationStore.endDateTime,
                            lastDate: DateTime.now()
                                .add(Duration(days: 60)));
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime:
                            TimeOfDay.fromDateTime(_creationStore.endDateTime),
                          );
                          inputEventEndAction(DateTimeField.combine(date, time));
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                      validator: (value){
                        if(_creationStore.startDateTime.difference
                          (_creationStore.endDateTime).inDays > 7){
                          return "Event Duration too long";
                        }
                        if (_creationStore.startDateTime.isAfter
                          (_creationStore.endDateTime)){
                          return "Event Start After Event End";
                        }
                        return null;
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.only(left: 16.0)),
                        Text("Websites"),
                        const Padding(padding: EdgeInsets.only(left: 200.0)),
                        RaisedButton(
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            onPressed: (){

                            },
                            child: Text("Press me",
                                style: TextStyle(color: Colors.white))
                        ),
                      ],
                    ),
                    ListView.separated(
                        itemCount: _creationStore.websites.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new Text(_creationStore.websites[index].URL);
                        },
                        separatorBuilder: (BuildContext context, int index)
                          => Divider()
                    )
                  ]
              ),
            )
        ),
      )
    );
  }

  void showWebsiteDialog(BuildContext context){
    showDialog<void>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Add a Website"),

        );
      }
    );
  }

}
