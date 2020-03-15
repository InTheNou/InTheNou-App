import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';

class Event {

  int _UID;
  String _title;
  String _description;
  DateTime _startDateTime;
  DateTime _endDateTime;
  DateTime _timestamp;
  Room _room;
  List<Tag> _tags;

  Event(this._UID,this._title, this._description,
      this._startDateTime, this._endDateTime, this._timestamp,
      this._room, this._tags);

  Event.newEvent(this._title, this._description,
      this._startDateTime, this._endDateTime, this._timestamp,
      this._room, this._tags){
    this._UID = 0;
  }

  Event.result(this._UID, this._title, this._description, this._startDateTime,
      this._endDateTime, this._room) {
    this._timestamp = null;
    this._tags = new List(10);
  }

}