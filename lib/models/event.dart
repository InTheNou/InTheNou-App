import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:intl/intl.dart';

/// Object representation of an Event in the System
///
/// It contains the identifiable and descriptive properties of the Event
/// entity in our database.
///
/// {@category Model}
class Event {

  /// Unique identifier of this Event entity
  /// It is represented in the API a "eid'
  int _UID;

  /// The title of the Event entity given by the Event Creator.
  /// Is it represented in the API as "etitle'
  String _title;

  /// The description of the Event entity given by the Event Creator.
  /// Is it represented in the API as "edescription'
  String _description;

  /// The name of the Event Creator of the Event entity.
  /// Is it represented in the API as "ecreator'
  String _creator;

  /// An optional image URL for the Event entity given by the Event Creator.
  /// Is it represented in the API as "photourl'
  String _image;

  /// The [DateTime] start time and date of the Event entity set by the Event
  /// Creator.
  /// Is it represented in the API as "estart'
  DateTime _startDateTime;

  /// The [DateTime] start time and date of the Event entity set by the Event
  /// Creator.
  /// Is it represented in the API as "eend'
  DateTime _endDateTime;

  /// The [DateTime] timestamp of when the Event entity was created.
  /// Is it represented in the API as "eend'
  DateTime _timestamp;

  /// The [Room] of the Event entity set by the Event Creator.
  /// Is it represented in the API as "room'
  Room _room;

  /// The optional [Website]s associated with the Event entity, set by the
  /// Event Creator.
  /// Is it represented in the API as "websites'
  List<Website> _websites;

  /// The [Tag]s of the Event entity set by the Event Creator.
  /// Is it represented in the API as "tags'
  List<Tag> _tags;

  /// The flag used to indicate if the Event entity is being followed by the
  /// current user.
  /// Is it represented in the API as "itype' being equal to "following"
  bool followed;

  /// The flag used to indicate if the Event entity was dismissed by the
  /// current user.
  /// Is it represented in the API as "itype' being equal to "dismissed"
  bool dismissed;

  /// The flag used to indicate if the Event entity was dismissed by the
  /// current user.
  /// Is it represented in the API as "itype' being equal to "dismissed"
  String recommended;

  /// The flag used to indicate if the Event entity was cancelled by the
  /// Event Creator.
  /// Is it represented in the API as "estatus' being equal to "active"
  String status;

  static DateFormat df = DateFormat("yyyy-MM-dd HH:mm:ss");


  /// Default constructor for any Event entity
  Event(this._UID,this._title, this._description, this._creator, this._image,
      this._startDateTime, this._endDateTime, this._timestamp,
      this._room, this._websites, this._tags, this.followed, this.dismissed,
      this.recommended, this.status);

  /// Constructor used for when showing Event entities as a list. This
  /// constructor only uses the bare minimum properties.
  Event.result({int UID, String title, String description,  String image,
    DateTime startDateTime,  DateTime endDateTime, DateTime timestamp,
    Room room, List<Tag> tags, bool followed, bool dismissed,
    String recommended, String status}) {
    this._UID = UID;
    this._title = title;
    this._description = description;
    this._creator = null;
    this._startDateTime = startDateTime;
    this._endDateTime = endDateTime;
    this._timestamp = timestamp;
    this._room = room;
    this._websites = null;
    this._tags = tags;
    this.followed = followed;
    this.dismissed = dismissed;
    this.recommended = recommended;
    this.status = status;
  }


  /// Factory constructor to create Event entities from json objects
  /// from the API.
  factory Event.fromJson(Map<String, dynamic> json) {
    if(json == null){
      return null;
    }
    Building b = Building.resultFromJson(json['room']['building']);
    return Event(
        json['eid'],
        json['etitle'],
        json['edescription'],
        json['ecreator']["display_name"],
        json['photourl'],
        df.parseUTC(json['estart']).toLocal(),
        df.parseUTC(json['eend']).toLocal(),
        df.parseUTC(json['ecreation']).toLocal(),
        Room.fromJson(json['room'], b),
        Website.jsonToList(json["websites"]),
        Tag.fromJsonToList(json["tags"]),
        json['itype'] == Utils.interactionTypeToString(InteractionType.Following),
        json['itype'] == Utils.interactionTypeToString(InteractionType.dismissed),
        json["recommendstatus"],
        json["estatus"] ?? "active"
    );
  }

  /// Factory constructor to create Building entities from [json] object
  /// from the API, using the Result constructor. The [isFollowed] parameter
  /// is to bypass the 'itype' returned from the API call.
  factory Event.resultFromJson(Map<String, dynamic> json,
      {bool isFollowed = false}) {
    Building b = Building.resultFromJson(json['room']['building']);
    return Event.result(
        UID: json['eid'],
        title: json['etitle'],
        description: json['edescription'],
        image: json['photourl'],
        startDateTime: df.parseUTC(json['estart']).toLocal(),
        endDateTime: df.parseUTC(json['eend']).toLocal(),
        timestamp: df.parseUTC(json['ecreation']).toLocal(),
        room: Room.fromJson(json['room'], b),
        followed: isFollowed ? true :
          json['itype'] == Utils.interactionTypeToString(InteractionType
              .Following),
        dismissed: json['itype'] == Utils.interactionTypeToString(InteractionType
            .dismissed),
        status: json["estatus"] ?? "active"
    );
  }

  /// Factory constructor to create Building entities from [json] object
  /// from the API, to be used for the Recommendation functionality.
  factory Event.recommendationFromJson(Map<String, dynamic> json) {
    return Event.result(
        UID: json['eid'],
        tags: Tag.fromJsonToList(json["tags"])
    );
  }

  /// Helper method to convert the Event object into json object to be sent
  /// to the API.
  Map<String, dynamic> toJson() => {
        "etitle": _title,
        "edescription": _description,
        "photourl": _image == null? null : _image.isEmpty ? null : _image,
        "ecreator": 0,
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
  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  DateTime get timestamp => _timestamp;
  Room get room => _room;
  List<Website> get websites => _websites;
  List<Tag> get tags => _tags;


  /// Helper method to format the [_startDateTime] as a readable string
  String getStartTimeString() {
    if (_startDateTime.month ==  DateTime.now().month){
      return DateFormat('EEE d: hh:mm aaa - ').format(_startDateTime);
    } else {
      return DateFormat('EEE, MMM d: hh:mm aaa - ').format(_startDateTime)
          + DateFormat('hh:mm aaa').format(_startDateTime);
    }
  }

  /// Helper method to format the [_endDateTime] as a readable string
  String getEEndTimeString() {
    if (_endDateTime.month ==  DateTime.now().month){
      return DateFormat('EEE d: hh:mm aaa - ').format(_endDateTime);
    } else {
      return DateFormat('EEE, MMM d: hh:mm aaa - ').format(_endDateTime)
          + DateFormat('hh:mm aaa').format(_endDateTime);
    }
  }

  /// Helper method to format the [_startDateTime] and [_endDateTime] into a
  /// readable string
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Event &&
              runtimeType == other.runtimeType &&
              _UID == other._UID;

  @override
  int get hashCode => _UID.hashCode;

}