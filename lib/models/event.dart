import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:intl/intl.dart';

class Event {

  int _UID;
  String _title;
  String _description;
  DateTime _startDateTime;
  DateTime _endDateTime;
  DateTime _timestamp;
  Room _room;
  List<Tag> _tags;
  bool _followed;

  Event(this._UID,this._title, this._description,
      this._startDateTime, this._endDateTime, this._timestamp,
      this._room, this._tags);

  Event.copy (Event event, bool followed){
    this._UID = event._UID;
    this._title = event._title;
    this._description = event._description;
    this._startDateTime = event._startDateTime;
    this._endDateTime = event._endDateTime;
    this._timestamp = event._timestamp;
    this._room = event._room;
    this._tags = event._tags;
    this._followed = followed;
  }

  Event.newEvent(this._title, this._description,
      this._startDateTime, this._endDateTime, this._timestamp,
      this._room, this._tags){
    this._UID = 0;
    this._followed = false;
  }

  Event.result(this._UID, this._title, this._description, this._startDateTime,
      this._endDateTime, this._room, this._followed) {
    this._timestamp = null;
    this._tags = new List(10);
  }

  List<Tag> get tags => _tags;

  Room get room => _room;

  DateTime get timestamp => _timestamp;

  DateTime get endDateTime => _endDateTime;

  String getEEndTimeString() {
    if (_startDateTime.month ==  DateTime.now().month){
      return DateFormat('EEE d: hh:mm aaa - ').format(_startDateTime);
    } else {
      return DateFormat('EEE, MMM d: hh:mm aaa - ').format(_startDateTime)
          + DateFormat('hh:mm aaa').format(_endDateTime);
    }
  }

  DateTime get startDateTime => _startDateTime;

  String getStartTimeString() {
    if (_startDateTime.month ==  DateTime.now().month){
      return DateFormat('EEE d: hh:mm aaa - ').format(_startDateTime);
    } else {
      return DateFormat('EEE, MMM d: hh:mm aaa - ').format(_startDateTime)
          + DateFormat('hh:mm aaa').format(_startDateTime);;
    }
  }

  String getDurationString() {
    if (_startDateTime.month ==  DateTime.now().month){
      if (_startDateTime.day == _endDateTime.day){
        return DateFormat('EEE d: hh:mm aaa - ').format(_startDateTime)
            + DateFormat('hh:mm aaa').format(_endDateTime);
      } else {
        return DateFormat('EEE d: hh:mm aaa - ').format(_startDateTime)
            + DateFormat('EEE d: hh:mm aaa').format(_endDateTime);
      }
    } else {
      if (_startDateTime.day == _endDateTime.day){
        return DateFormat('EEE, MMM d: hh:mm aaa - ').format(_startDateTime)
            + DateFormat('hh:mm aaa').format(_endDateTime);
      } else {
        return DateFormat('EEE, MMM d: hh:mm aaa - ').format(_startDateTime)
            + DateFormat('EEE, MMM d: hh:mm aaa').format(_endDateTime);
      }
    }
  }

  String get description => _description;

  String get title => _title;

  int get UID => _UID;

  bool get followed => _followed;


}