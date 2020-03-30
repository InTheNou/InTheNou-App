import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:InTheNou/repos/infobase_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class EventCreationStore extends flux.Store {

  static final flux.StoreToken eventCreationStoreToken = new flux.StoreToken(
      new EventCreationStore());

  static final InfoBaseRepo _infoBaseRepo = new InfoBaseRepo();
  static final EventsRepo _eventsRepo = new EventsRepo();

  Event _newEvent;
  String _title;
  String _description;
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
    triggerOnAction(submitEventAction, (_){
      _newEvent = new Event(0,_title, _description,"", "", _startDateTime,
          _endDateTime,DateTime.now(), _selectedRoom, _websites,
        _selectedTags, false, null);
      _eventsRepo.createEvent(0, _newEvent);
      reset();
    });
    triggerOnAction(discardEventAction, (_){
      reset();
    });
    triggerOnAction(getBuildingsAction, (_){
      _buildings = _infoBaseRepo.dummyBuildings;
    });
    triggerOnAction(getAllTagsAction, (_){
      _allTagsFromRepo = new List.generate(5, (index) =>
        new Tag("Tag$index", 10));
      _allTags = new Map<Tag,bool>.fromIterable(_allTagsFromRepo,
          key: (tag) => tag,
          value: (tag) => false
      );
      if(_searchTags.isEmpty){
        _searchTags = new Map.from(_allTags);
      }
    });
    triggerOnAction(inputEventTitleAction, (String title){
      _title = title;
    });
    triggerOnAction(inputEventDescriptionAction, (String description){
      _description = description;
    });
    triggerOnAction(inputEventDateAction, (MapEntry<bool, DateTime> dateTime){
      if(dateTime.key){
        _startDateTime = dateTime.value;
      } else{
        _endDateTime = dateTime.value;
      }
    });
    triggerOnAction(buildingSelectAction, (Building building){
      _selectedBuilding = building;
      _selectedFloor = null;
      _selectedRoom = null;
      _roomsInBuilding = new List();
      createFloors(building);
    });
    triggerOnAction(floorSelectAction, (Floor floor){
      _roomsInBuilding = _infoBaseRepo.getRoomsOfFloor(_selectedBuilding.UID,
          floor.floorNumber);
      _selectedFloor = floor;
      _selectedRoom = null;
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
        if(key.name.contains(search)){
          _searchTags.putIfAbsent(key, () => value);
        }
      });
    });
  }

  void createFloors(Building building){
    _floors = new List.generate(building.numFloors,
            (index) => Utils.ordinalNumber(index+1));
  }

  void reset(){
    _title = null;
    _description = null;
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


  String get title => _title;
  String get description => _description;
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
  Map<Tag, bool> get searchTags => _searchTags;}

final flux.Action submitEventAction = new flux.Action();
final flux.Action discardEventAction = new flux.Action();
final flux.Action getBuildingsAction = new flux.Action();
final flux.Action getAllTagsAction = new flux.Action();
final flux.Action<String> inputEventTitleAction = new flux.Action<String>();
final flux.Action<String> inputEventDescriptionAction = new flux
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
