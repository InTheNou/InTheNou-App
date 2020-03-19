import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class EventCreationStore extends flux.Store {

  static final InfoBaseStore _infoBaseStore = new InfoBaseStore();
  static final UserStore _userStore = new UserStore();
  static final EventsRepo _eventsRepo = new EventsRepo();

  Event _newEvent;
  String _title;
  String _description;
  DateTime _startDateTime;
  DateTime _endDateTime;
  List<Building> _buildings;
  List<Room> _roomsInBuilding;
  Room _selectedRoom;
  List<Website> _websites = new List();

  List<Tag> _allTagsFromRepo;
  Map<Tag,bool> _allTags;
  Map<Tag,bool> _searchTags;
  List<Tag> _selectedTags = new List();

  EventCreationStore() {
    _allTagsFromRepo = new List.generate(30, (index) => new Tag("Tag$index", 10));
//    _searchTags = new List.from(_allTags);
    
    _allTags = new Map<Tag,bool>.fromIterable(_allTagsFromRepo,
      key: (tag) => tag,
      value: (tag) => false
    );
    _searchTags = new Map.from(_allTags);

    triggerOnAction(submitEventAction, (_){
      _newEvent = new Event.newEvent(_title, _description, _startDateTime,
          _endDateTime, _selectedRoom, _websites, _selectedTags);
      _eventsRepo.createEvent(0, _newEvent);
    });
    triggerOnAction(inputEventTitleAction, (String title){
      _title = title;
    });
    triggerOnAction(inputEventDescriptionAction, (String description){
      _description = description;
    });
    triggerOnAction(inputEventStartAction, (DateTime dateTime){
      _startDateTime = dateTime;
    });
    triggerOnAction(inputEventEndAction, (DateTime dateTime){
      _endDateTime = dateTime;
    });
    triggerOnAction(addWebsiteAction, (Website website){
      _websites.add(website);
    });
    triggerOnAction(removeWebsiteAction, (Website website){
      _websites.remove(website);
    });

    triggerOnAction(selectedTagAction, (MapEntry<Tag, bool> tag){
      if (tag.value){
        _selectedTags.add(tag.key);
        if(_searchTags.containsKey(tag.key)){
          _searchTags.update(tag.key, (value) => tag.value);
        }
      } else {
        _selectedTags.remove(tag.key);
        if(_searchTags.containsKey(tag.key)){
          _searchTags.update(tag.key, (value) => tag.value);
        }
      }
    });
    triggerOnAction(searchedTagAction, (String search){
      _allTags.forEach((key, value) {
        if(key.name.contains(search)){
          _searchTags.putIfAbsent(key, () => value);
        }
      });
    });
  }

  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  List<Website> get websites => _websites;

  List<Tag> get selectedTags => _selectedTags;
  Map<Tag, bool> get searchTags => _searchTags;
}

final flux.Action submitEventAction = new flux.Action();

final flux.Action<String> inputEventTitleAction = new flux.Action<String>();
final flux.Action<String> inputEventDescriptionAction = new flux
    .Action<String>();

final flux.Action<DateTime> inputEventStartAction = new flux.Action<DateTime>();
final flux.Action<DateTime> inputEventEndAction = new flux.Action<DateTime>();
final flux.Action<Website> addWebsiteAction = new flux.Action<Website>();
final flux.Action<Website> removeWebsiteAction = new flux.Action<Website>();

final flux.Action<MapEntry<Tag, bool>> selectedTagAction =
    new flux.Action<MapEntry<Tag, bool>>();
final flux.Action<String> searchedTagAction = new flux.Action<String>();

final flux.StoreToken eventCreationStoreToken = new flux.StoreToken(
    new EventCreationStore());