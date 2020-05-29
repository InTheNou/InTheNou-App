import 'package:InTheNou/models/phone_number.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/website.dart';

/// Object representation of an Service in the System
///
/// It contains the identifiable and descriptive properties of the Service
/// entity in our database.
///
/// {@category Model}
class Service {

  int _UID;
  String _name;
  String _description;
  String _roomCode;
  String _schedule;
  List<PhoneNumber> _numbers;
  List<Website> _websites;

  /// The Default Constructor
  Service(this._UID, this._name, this._description, this._roomCode,
      this._schedule, this._numbers, this._websites);

  /// Factory constructor to create Service entities from [json] objects
  /// from the API.
  ///
  /// It also receives a [Room] entity via [room] to populate the
  /// [Service._roomCode].
  factory Service.fromJson(Map<String, dynamic> json, Room room) {
    return Service(
      json['sid'],
      json['sname'],
      json['sdescription'],
      room.code,
      json['sschedule'].toString(),
      PhoneNumber.jsonToList(json['numbers']),
      Website.jsonToList(json["websites"]),
    );
  }

  /// Unique identifier of this Service entity
  /// It is represented in the API a "eid'
  int get UID => _UID;

  /// The given name of this Service entity
  /// It is represented in the API a "sid'
  String get name => _name;

  /// The given description of this Service entity
  /// It is represented in the API a "sdescription'
  String get description => _description;

  /// The [Room.code] where this Service is located
  /// It is represented in the API a "eid'
  String get roomCode => _roomCode;

  /// The operation schedule that this Service runs on
  /// It is represented in the API a "sschedule'
  String get schedule => _schedule;

  /// The [PhoneNumber]s associated with this Service entity
  /// It is represented in the API a "PNumbers'
  List<PhoneNumber> get numbers => _numbers;

  /// The [Website]s associated with this Service entity
  /// It is represented in the API a "Websites'
  List<Website> get websites => _websites;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Service &&
              runtimeType == other.runtimeType &&
              _UID == other._UID;

  @override
  int get hashCode => _UID.hashCode;

}