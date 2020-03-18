import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/stores/infobase_store.dart';
import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class EventCreationStore extends flux.Store {

  Event _newEvent;
  String _title;
  String _description;
  DateTime _startDateTime;
  DateTime _endDateTime;
  List<Building> _buildings;
  List<Room> _roomsInBuilding;
  Room _selectedRoom;
  List<Website> _websites;
  List<Tag> _allTags;
  List<Tag> _selectedTags = new List(10);

  static final InfoBaseStore _infoBaseStore = new InfoBaseStore();
  static final UserStore _userStore = new UserStore();

  EventCreationStore() {
    _startDateTime = DateTime.now();
    _endDateTime = DateTime.now();
    triggerOnAction(submitEventAction, (_){
      _newEvent = new Event.newEvent(_title, _description, _startDateTime,
          _endDateTime, _selectedRoom, _websites, _selectedTags);
    });
    triggerOnAction(inputEventStartAction, (DateTime dateTime){
      _startDateTime = dateTime;
    });
    triggerOnAction(inputEventEndAction, (DateTime dateTime){
      _endDateTime = dateTime;
    });

    triggerOnAction(selectedTagAction, (MapEntry<Tag, bool> tag){
      if (tag.value){
        _selectedTags.add(tag.key);
      } else {
        _selectedTags.remove(tag.key);
      }
    });
    triggerOnAction(searchedTagAction, (String search){

    });
  }

  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  List<Website> get websites => _websites;


}

final flux.Action submitEventAction = new flux.Action();

final flux.Action<DateTime> inputEventStartAction = new flux.Action<DateTime>();
final flux.Action<DateTime> inputEventEndAction = new flux.Action<DateTime>();

final flux.Action<MapEntry<Tag, bool>> selectedTagAction =
    new flux.Action<MapEntry<Tag, bool>>();
final flux.Action<String> searchedTagAction = new flux.Action<String>();

final flux.StoreToken EventCreationStoreToken = new flux.StoreToken(
    new EventCreationStore());