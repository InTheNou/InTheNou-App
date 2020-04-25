import 'package:InTheNou/assets/colors.dart';
import 'package:InTheNou/assets/validators.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_manager.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/event_creation_store.dart';
import 'package:InTheNou/views/EventFeed/tag_selection_widget.dart';
import 'package:InTheNou/views/EventFeed/website_alert_dialog.dart';
import 'package:dio/dio.dart';
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
  final _format = DateFormat("EE, MMMM d, yyyy 'at' h:mma");
  final DateTime _initialDaeTime = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day);

  Dio _dio = Dio();
  DialogService _dialogService = DialogService();
  ScrollController _scrollController;

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
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _creationStore.creationResult.then((value){
      if(value){
        WidgetsBinding.instance.addPostFrameCallback((_) async{
          _creationStore.creationResult = Future.value(false);
          // Remove the Loading AlertDialog if it's showing
          Navigator.of(context).popUntil(ModalRoute.withName('/home'));
        });
      }
    });

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Event Creation"),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              child: Text(
                "SUBMIT"
              ),
              onPressed: () => _validateEventSubmit()
            )
          ],
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => _showExitWarning(),
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Form(
              key: _formKey,
              onWillPop: () => _showExitWarning(),
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0,
                    left: 8.0, right: 8.0),
                child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Padding(padding: EdgeInsets.only(left: 8.0)),
                          Expanded(
                            child: Text("Event Information",
                                style: Theme.of(context).textTheme.subtitle1),
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                      //
                      //Title
                      TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor,
                                width: 1.0),
                          ),
                          border: const OutlineInputBorder(),
                          labelText: "Event Title *",
                        ),
                        autovalidate: _autoValidate,
                        maxLines: 1,
                        maxLength: 50,
                        textInputAction: TextInputAction.done,
                        initialValue: _creationStore.title,
                        validator: (title) => Validators.validateTitle(title),
                        onChanged: (String title) =>
                            inputEventTitleAction(title.trim()),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                      //
                      // Description
                      TextFormField(
                        decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: primaryColor,
                                  width: 1.0),
                            ),
                            border: const OutlineInputBorder(),
                            labelText: "Description *"),
                        autovalidate: _autoValidate,
                        maxLines: null,
                        maxLength: 400,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        initialValue: _creationStore.description,
                        validator: (description) =>
                            Validators.validateDescription(description),
                        onChanged: (String description) =>
                            inputEventDescriptionAction(description.trim()),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                      //
                      // Image
                      TextFormField(
                        decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: primaryColor,
                                  width: 1.0),
                            ),
                            border: const OutlineInputBorder(),
                            labelText: "Event Image URL"),
                        autovalidate: _autoValidate,
                        maxLines: 1,
                        maxLength: 400,
                        textInputAction: TextInputAction.done,
                        initialValue: _creationStore.image,
                        validator: (image) => Validators.validateImage(image),
                        onChanged: (String image) =>
                            inputEventImageAction(image.trim()),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                      //
                      //Dates
                      DateTimeField(
                        format: _format,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor,
                                width: 1.0),
                          ),
                          border: const OutlineInputBorder(),
                          labelText: "Event Start Date *",
                          helperText: "Duration must be between 5mins and 7 "
                              "days",
                        ),
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
                                return DateTimeField.combine(date, time);
                              } else {
                            return currentValue;
                          }
                        },
                        validator: (date) =>
                            Validators.validateDate(date,
                                _creationStore.startDateTime,
                                _creationStore.endDateTime),
                        onChanged: (value) {
                          inputEventDateAction(MapEntry(true,
                              value));
                          _formKey.currentState.setState(() {
                            _autoValidateDates = true;
                            _endDateEnable = value != null;
                          });
                        },
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                      DateTimeField(
                        format: _format,
                        enabled: _endDateEnable,
                        autofocus: false,
                        focusNode: FocusNode(canRequestFocus: false),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor,
                                width: 1.0),
                          ),
                          border: const OutlineInputBorder(),
                          labelText: "Event End Date *",
                          helperText: "Duration must be between 5mins and 7 "
                                "days",
                        ),
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
                            return DateTimeField.combine(date, time);
                          } else {
                            return currentValue;
                          }
                        },
                        validator: (date) => Validators.validateDate(
                            date,
                            _creationStore.startDateTime,
                            _creationStore.endDateTime),
                        onChanged: (value){
                          inputEventDateAction(MapEntry(false,
                              value));
                        },
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 16.0)),
                      //
                      // Location
                      Row(
                        children: <Widget>[
                          const Padding(padding: EdgeInsets.only(left: 8.0)),
                          Expanded(
                            child: Text("Location *",
                                style: Theme.of(context).textTheme.subtitle1),
                          ),
                          const Padding(padding: EdgeInsets.only(left: 8.0)),
                        ],
                      ),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 8.0),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).accentColor))),
                            autovalidate: _autoValidate,
                            hint: Text("Building *"),
                            disabledHint: Text("Building *",
                                style: Theme.of(context).textTheme.subtitle1
                                    .copyWith(fontWeight: FontWeight.w200)),
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
                            decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).accentColor))),
                            autovalidate: _autoValidate,
                            hint: Text("Floor *"),
                            disabledHint: Text("Floor *",
                                style: Theme.of(context).textTheme.subtitle1
                                    .copyWith(fontWeight: FontWeight.w200)),
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
                          child:DropdownButtonFormField(
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).accentColor))),
                              autovalidate: _autoValidate,
                              hint: Text("Room *"),
                              disabledHint: Text("Room *",
                                  style: Theme.of(context).textTheme.subtitle1
                                      .copyWith(fontWeight: FontWeight.w200)),
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
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Website Links: ",
                                    style: Theme.of(context).textTheme.subtitle1
                                  ),
                                  TextSpan(
                                    text: "${_creationStore.websites.length}/10",
                                    style: Theme.of(context).textTheme
                                            .subtitle1.copyWith(
                                            fontWeight: FontWeight.w300
                                        ),
                                  )
                                ]
                              ),
                            ),
                          ),
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: (){
                                if(Validators.validateWebsiteQuantity(
                                    _creationStore.websites)){
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) =>
                                          WebsiteAlertDialog(_creationStore.websites)
                                  );
                                }
                                else {
                                  _showWebsiteWarning();
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
                          RichText(
                            text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Select from 3 to 10 Tags: ",
                                      style: Theme.of(context).textTheme.subtitle1
                                  ),
                                  TextSpan(
                                    text: "${_creationStore.selectedTags.length}/10",
                                    style: Theme.of(context).textTheme
                                        .subtitle1.copyWith(
                                        fontWeight: FontWeight.w300
                                    ),
                                  )
                                ]
                            ),
                          ),
                        ],
                      ),
                      TagSelectionWidget(),
                    ]
                ),
              )
          ),
        )
      ),
    );
  }

  void _validateEventSubmit() async {
    if(_formKey.currentState.validate()
        && Validators.validateSelectedTags(_creationStore.selectedTags)){
      Response response;
      bool result = true;
      if(_creationStore.image != null && _creationStore.image.isNotEmpty){
        _dialogService.showLoadingDialog(
            title: "Verifying Image");
        try{
          response = await _dio.get(_creationStore.image);
          result = response.headers["Content-Type"].toString().contains("image");
        } catch(e){
          result = false;
        }
        _dialogService.dialogComplete(DialogResponse(result: true));
      }
      if (!result){
        _dialogService.showDialog(
            type: DialogType.Alert,
            title: "Invalid Image",
            description: "No image was found in the provided link, please "
                "verify it and retry.");
      } else {
        submitEventAction();
      }
    } else if(!_formKey.currentState.validate()){
      _formKey.currentState.save();
      setState(() {
        _autoValidate = true;
      });
      _scrollController.animateTo(0.0,
          curve: Curves.ease, duration: Duration(seconds: 1));
    }
    else{
      _scrollController.animateTo(10.0,
          curve: Curves.ease, duration: Duration(seconds: 1));
      _dialogService.showDialog(
          type: DialogType.Alert,
          title: "Incorrect number of Tags",
          description: "Please choose between 3 to 10 Tags that best describe the Event "
              "before Submitting.");
      _formKey.currentState.save();
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Future<bool> _showExitWarning() async{
    if(_creationStore.hasNoChanges()){
      Navigator.pop(context);
      return false;
    }
    await discardEventAction();
    Navigator.pop(context);
    return false;
  }

  void _showWebsiteWarning(){
    _dialogService.showDialog(
        type: DialogType.Alert,
        title: "Links limit",
        description: 'You have reached the limit of 10 links associated with an'
            ' Event.');
  }

}
