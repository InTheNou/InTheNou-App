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

  List<Tag> _allTagsFromRepo = new List();
  Map<Tag,bool> _allTags = new Map();
  Map<Tag,bool> _searchTags = new Map();
  List<Tag> _selectedTags = new List();

  EventCreationStore() {
    triggerOnAction(submitEventAction, (_) async{
      _dialogService.showLoadingDialog(
          title: "Creating Event");

      _newEvent = new Event(0,_title, _description, "",
          _image == null ? null : _image.isEmpty ? null : _image,
          _startDateTime, _endDateTime, DateTime.now(), _selectedRoom,
          _websites, _selectedTags, false, null, "active");

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
              type: DialogType.Alert,
              title: "Creation Failed",
              description: "The Event was not able to be Created please try "
                  "again.");
        }
      }).catchError((e){
        _dialogService.showDialog(
            type: DialogType.Alert,
            title: "Error",
            description: e.toString());
      });
    });
    triggerOnAction(discardEventAction, (_){
      reset();
    });
    triggerOnConditionalAction(getBuildingsAction, (_) async{
      return _infoBaseRepo.getAllBuildings().then((buildings){
        _buildings = buildings;
        return true;
      });
    });
    triggerOnAction(getAllTagsAction, (_){
      return _tagRepo.getAllTags().then((tags) {
        _allTagsFromRepo = tags;
        _allTags = new Map<Tag,bool>.fromIterable(_allTagsFromRepo,
            key: (tag) => tag,
            value: (tag) => false
        );
        if(_searchTags.isEmpty){
          _searchTags = new Map.from(_allTags);
        }
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
    triggerOnConditionalAction(buildingSelectAction, (Building building){
      _selectedFloor = null;
      _selectedRoom = null;
      _roomsInBuilding = new List();
      return _infoBaseRepo.getBuilding(building.UID).then((value) {
        _selectedBuilding = value;
        _floors = selectedBuilding.floors;
        return true;
      });
    });
    triggerOnConditionalAction(floorSelectAction, (Floor floor) async{
      _selectedFloor = floor;
      _selectedRoom = null;
      return _infoBaseRepo.getRoomsOfFloor(_selectedBuilding.UID,
          floor.floorNumber).then((value){
        _roomsInBuilding = value;
        return true;
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
      if(_searchTags.containsKey(tag.key)){
        _searchTags.update(tag.key, (value) => tag.value);
        _allTags.update(tag.key, (value) => tag.value);
      }
      if (tag.value){
        _selectedTags.add(tag.key);
      } else {
        _selectedTags.remove(tag.key);
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
    _buildings = new List();
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
    print(_title);
    print(_description);
    print(_image);
    print(_startDateTime);
    print(_endDateTime);
    print(_selectedBuilding);
    print(_selectedFloor);
    print(_selectedRoom);
    print(_websites);
    print(_selectedTags);


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
