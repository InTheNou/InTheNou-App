import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:intl/intl.dart';

class Event {

  int _UID;
  String _title;
  String _description;
  String _creator;
  String _image;
  DateTime _startDateTime;
  DateTime _endDateTime;
  DateTime _timestamp;
  Room _room;
  List<Website> _websites;
  List<Tag> _tags;
  bool followed;

  Event(this._UID,this._title, this._description, this._creator, this._image,
      this._startDateTime, this._endDateTime, this._timestamp,
      this._room, this._websites, this._tags, this.followed);

  Event.copy (Event event){
    this._UID = event._UID;
    this._title = event._title;
    this._description = event._description;
    this._creator = event._creator;
    this._startDateTime = event._startDateTime;
    this._endDateTime = event._endDateTime;
    this._timestamp = event._timestamp;
    this._room = event._room;
    this._websites = event._websites;
    this._tags = event._tags;
    this.followed = event.followed;
  }

  Event.newEvent(this._title, this._description, this._startDateTime,
      this._endDateTime, this._room, this._websites, this._tags){
    this._UID = -1;
    this.followed = false;
  }

  Event.result(this._UID, this._title, this._description, this._startDateTime,
      this._endDateTime, this._room, this.followed) {
    this._timestamp = null;
    this._tags = new List(10);
  }

  int get UID => _UID;
  String get title => _title;
  String get description => _description;
  String get creator => _creator;
  String get image => _image;
  DateTime get endDateTime => _endDateTime;
  DateTime get timestamp => _timestamp;
  Room get room => _room;
  List<Website> get websites => _websites;
  List<Tag> get tags => _tags;

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

  @override
  String toString() {
    return 'Event{_UID: $_UID, _title: $_title, _description: $_description, _startDateTime: $_startDateTime, _endDateTime: $_endDateTime, _timestamp: $_timestamp, _room: $_room, _websites: $_websites, _tags: $_tags, followed: $followed}';
  }


}