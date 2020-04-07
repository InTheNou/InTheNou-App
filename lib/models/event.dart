import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/building.dart';
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
  bool recommended;

  Event(this._UID,this._title, this._description, this._creator, this._image,
      this._startDateTime, this._endDateTime, this._timestamp,
      this._room, this._websites, this._tags, this.followed, this.recommended);

  Event.copy (Event event){
    this._UID = event._UID;
    this._title = event._title;
    this._description = event._description;
    this._creator = event._creator;
    this._image = event._image;
    this._startDateTime = event._startDateTime;
    this._endDateTime = event._endDateTime;
    this._timestamp = event._timestamp;
    this._room = event._room;
    this._websites = event._websites;
    this._tags = event._tags;
    this.followed = event.followed;
    this.recommended = event.recommended;
  }

  Event.result({int UID, String title, String description,  String image,
      DateTime startDateTime,  DateTime endDateTime, DateTime timestamp,
     Room room, bool followed}) {
    this._UID = UID;
    this._title = title;
    this._description = description;
    this._creator = null;
    this._startDateTime = startDateTime;
    this._endDateTime = endDateTime;
    this._timestamp = timestamp;
    this._room = room;
    this._websites = null;
    this._tags = new List(10);
    this.followed = followed;
    this.recommended = null;
  }

  static DateFormat df = DateFormat("yyyy-MM-dd HH:mm:ss");
  factory Event.fromJson(Map<String, dynamic> json) {
    if(json == null){
      return null;
    }
    Building b = Building.resultFromJson(json['room']['building']);
    return Event(
        json['eid'],
        json['etitle'],
        json['edescription'],
        json['ecreator']["first_name"],
        json['photourl'],
        df.parseUTC(json['estart']).toLocal(),
        df.parseUTC(json['eend']).toLocal(),
        df.parseUTC(json['ecreation']).toLocal(),
        Room.fromJson(json['room'], b),
        Website.jsonToList(json["websites"]),
        Tag.fromJsonToList(json["tags"]),
        json['itype'] == "following",
        null
    );
  }

  factory Event.resultFromJson(Map<String, dynamic> json,
      {bool isFollowed = false}) {
    return Event.result(
        UID: json['eid'],
        title: json['etitle'],
        description: json['edescription'],
        image: json['photourl'],
        startDateTime: df.parseUTC(json['estart']).toLocal(),
        endDateTime: df.parseUTC(json['eend']).toLocal(),
        timestamp: df.parseUTC(json['ecreation']).toLocal(),
        room: Room.forEventFromJson(json['room']),
        followed: isFollowed ? true : json['itype'] == "following"
    );
  }

  Map<String, dynamic> toJson() => {
        "etitle": _title,
        "edescription": _description,
        "photourl": _image.isEmpty ? null : _image,
        "ecreator": 4,
        "estart": Utils.formatTimeStamp(_startDateTime.toUtc()),
        "eend": Utils.formatTimeStamp(_endDateTime.toUtc()),
        "roomid": _room.UID,
        "tags": Tag.toJsonList(_tags),
        "websites": Website.toJsonList(_websites)
  };

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
    return 'Event{_UID: $_UID, _title: $_title, _description: $_description, _creator: $_creator, _image: $_image, _startDateTime: $_startDateTime, _endDateTime: $_endDateTime, _timestamp: $_timestamp, _room: $_room, _websites: $_websites, _tags: $_tags, followed: $followed, recommended: $recommended}';
  }


}