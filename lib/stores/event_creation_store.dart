import 'dart:math';

import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_manager.dart';
import 'package:InTheNou/dialog_service.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:InTheNou/repos/infobase_repo.dart';
import 'package:InTheNou/repos/tag_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class EventCreationStore extends flux.Store {

  static final flux.StoreToken eventCreationStoreToken = new flux.StoreToken(
      new EventCreationStore());

  static final InfoBaseRepo _infoBaseRepo = new InfoBaseRepo();
  static final EventsRepo _eventsRepo = new EventsRepo();
  static final TagRepo _tagRepo = new TagRepo();

  Random rand = Random();

  Future<bool> creationResult = Future.value(false);

  DialogService _dialogService = DialogService();

  Event _newEvent;
  String _title;
  String _description;
  String _image;
  DateTime _startDateTime;
  DateTime _endDateTime;
  List<Building> _buildings = new List();
  Building _selectedBuilding;
  List<Floor> _floors = new List();
  Floor _selectedFloor;

  List<Room> _roomsInBuilding = new List();
  Room _selectedRoom;
  List<Website> _websites = new List();

  Map<Tag,bool> _allTags = new Map();
  Map<Tag,bool> _searchTags = new Map();
  List<Tag> _selectedTags = new List();

  EventCreationStore() {
    triggerOnAction(submitEventAction, (_) async{
      DialogResponse confirmation = await _dialogService.showDialog(
          type: DialogType.ImportantAlert,
          title: "Confirm Event",
          description: "Are you sure you want to submit this event? \nNo further "
              "changes can be made to the event, except for canceling.",
          primaryButtonTitle: "CONFIRM",
          secondaryButtonTitle: "CANCEL",
          dismissible: false);
      if(!confirmation.result){
        return;
      }

      _dialogService.showLoadingDialog(
          title: "Creating Event");

      _newEvent = new Event(0,_title, _description, "",
          _image == null ? null : _image.isEmpty ? null : _image,
          _startDateTime, _endDateTime, DateTime.now(), _selectedRoom,
          _websites, _selectedTags, false, false, null, "active");

      _eventsRepo.createEvent(_newEvent).then((result) async{
        _dialogService.dialogComplete(DialogResponse(result: true));
        if(result){
          await _dialogService.showDialog(
              type: DialogType.Alert,
              title: "Creation Success",
              description: "The Event has been Created.",
              dismissible: false
          );
          creationResult = Future.value(result);
          trigger();
          reset();
        } else {
          _dialogService.showDialog(
              type: DialogType.Error,
              title: "Creation Failed",
              description: "The Event was not able to be Created please try "
                  "again.");
        }
      }).catchError((e){
        _dialogService.showDialog(
            type: DialogType.Error,
            title: "Creation Failed",
            description: e.toString());
      });
    });
    triggerOnAction(discardEventAction, (_) async{
      DialogResponse response = await _dialogService.showDialog(
          type: DialogType.Alert,
          title: "You have made some changes",
          description: 'Would you like to save your progress in the '
              'Event Creation temporerally?. \nIt will be discarted '
              'upon restart of the application.',
          primaryButtonTitle: "SAVE",
          secondaryButtonTitle: "DISCARD",
          dismissible: false);
      if(!response.result){
        reset();
      }
    });
    triggerOnAction(getBuildingsAction, (_) async{
      _infoBaseRepo.getAllBuildings(0, PAGINATION_GET_ALL).then((buildings){
        _buildings = buildings;
        trigger();
      }).catchError((e){
        _dialogService.showDialog(
            type: DialogType.Error,
            title: "Unable to get Buildings",
            description: e.toString());
      });
    });
    triggerOnAction(getAllTagsAction, (_){
      _tagRepo.getAllTags().then((tags) {
        _allTags = new Map<Tag,bool>.fromIterable(tags,
            key: (tag) => tag,
            value: (tag) => false
        );
        if(_searchTags.isEmpty){
          _searchTags = new Map.from(_allTags);
        }
        trigger();
      }).catchError((e){
        _dialogService.showDialog(
            type: DialogType.Error,
            title: "Unable to get Tags",
            description: "Please try again.");
      });
    });
    triggerOnAction(inputEventTitleAction, (String title){
      _title = title;
    });
    triggerOnAction(inputEventDescriptionAction, (String description){
      _description = description;
    });
    triggerOnAction(inputEventImageAction, (String image){
      _image = image;
    });
    triggerOnAction(inputEventDateAction, (MapEntry<bool, DateTime> dateTime){
      if(dateTime.key){
        _startDateTime = dateTime.value;
      } else{
        _endDateTime = dateTime.value;
      }
    });
    triggerOnAction(buildingSelectAction, (Building building){
      _selectedFloor = null;
      _selectedRoom = null;
      _roomsInBuilding = new List();
      _infoBaseRepo.getBuilding(building.UID).then((value) {
        _selectedBuilding = value;
        _floors = selectedBuilding.floors;
        trigger();
      }).catchError((e){
        _dialogService.showDialog(
            type: DialogType.Error,
            title: "Unable to get Floors of Building",
            description: e.toString());
      });
    });
    triggerOnAction(floorSelectAction, (Floor floor) async{
      _selectedFloor = floor;
      _selectedRoom = null;
      _infoBaseRepo.getRoomsOfFloor(_selectedBuilding.UID,
          floor.floorNumber).then((value){
        _roomsInBuilding = value;
        trigger();
      }).catchError((e){
        _dialogService.showDialog(
            type: DialogType.Error,
            title: "Unable to get Rooms of Floor",
            description: e.toString());
      });
    });
    triggerOnAction(roomSelectAction, (Room room){
      _selectedRoom = room;
    });
    triggerOnAction(modifyWebsiteAction, (MapEntry website){
      if(website.key){
        _websites.add(website.value);
      } else{
        _websites.remove(website.value);
      }
    });
    triggerOnAction(selectedTagAction, (MapEntry<Tag, bool> tag){
      if (tag.value){
        if(_selectedTags.length > 9){
          _dialogService.showDialog(
              type: DialogType.Alert,
              title: "Tag Limit Reached",
              description: "You have reached the limit of 10 Tags for the "
                  "Event.");
          return;
        } else {
          _selectedTags.add(tag.key);
        }
      } else {
        _selectedTags.remove(tag.key);
      }
      if(_searchTags.containsKey(tag.key)){
        _searchTags.update(tag.key, (value) => tag.value);
        _allTags.update(tag.key, (value) => tag.value);
      }
    });
    triggerOnAction(searchedTagAction, (String search){
      _searchTags.clear();
      _allTags.forEach((key, value) {
        if(key.name.toUpperCase().contains(search.toUpperCase())){
          _searchTags.putIfAbsent(key, () => value);
        }
      });
    });
  }

  void reset(){
    _title = null;
    _description = null;
    _image = null;
    _startDateTime = null;
    _endDateTime = null;
    _selectedBuilding = null;
    _floors = new List();
    _selectedFloor = null;
    _roomsInBuilding = new List();
    _selectedRoom = null;
    _websites = new List();
    _searchTags = new Map();
    _selectedTags = new List();
  }

  bool hasNoChanges(){
    return _title == null && _description == null &&
        (_image == null || _image.isEmpty) && _startDateTime == null &&
        _endDateTime == null && _selectedBuilding == null &&
        _selectedFloor == null && _selectedRoom == null &&
        _websites.length==0 && _selectedTags.length==0;
  }


  String get title => _title;
  String get description => _description;
  String get image => _image;
  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  List<Building> get buildings => _buildings;
  Building get selectedBuilding => _selectedBuilding;
  List<Room> get roomsInBuilding => _roomsInBuilding;
  Room get selectedRoom => _selectedRoom;
  List<Floor> get floors => _floors;
  Floor get selectedFloor => _selectedFloor;
  List<Website> get websites => _websites;
  List<Tag> get selectedTags => _selectedTags;
  Map<Tag, bool> get searchTags => _searchTags;
}

final flux.Action submitEventAction = new flux.Action();
final flux.Action discardEventAction = new flux.Action();
final flux.Action getBuildingsAction = new flux.Action();
final flux.Action getAllTagsAction = new flux.Action();
final flux.Action<String> inputEventTitleAction = new flux.Action<String>();
final flux.Action<String> inputEventDescriptionAction = new flux
    .Action<String>();
final flux.Action<String> inputEventImageAction = new flux
    .Action<String>();
final flux.Action<MapEntry<bool, DateTime>> inputEventDateAction = new flux
    .Action();
final flux.Action<Building> buildingSelectAction = new flux.Action<Building>();
final flux.Action<Floor> floorSelectAction = new flux.Action<Floor>();
final flux.Action<Room> roomSelectAction = new flux.Action<Room>();
final flux.Action<MapEntry<bool, Website>> modifyWebsiteAction = new flux
    .Action();
final flux.Action<MapEntry<Tag, bool>> selectedTagAction =
    new flux.Action<MapEntry<Tag, bool>>();
final flux.Action<String> searchedTagAction = new flux.Action<String>();
