import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/service.dart';

/// Object representation of a Room inside a [Building] in the System.
///
/// It contains the identifiable and descriptive properties of the Room
/// entity in our database, as well as the associated [Service]s that are
/// provided inside this room.
///
/// {@category Model}
class Room {

  int _UID;
  String _code;
  String _building;
  int _floor;
  String _description;
  String _department;
  int _occupancy;
  String _custodianEmail;
  Coordinate _coordinates;

  /// A list of [Service]s that are provided inside this room.
  List<Service> services;

  /// The Default constructor
  Room(this._UID, this._code, this._building, this._floor, this._description,
      this._department, this._occupancy, this._custodianEmail, this._coordinates);

  /// Alternate constructor for creating room instances to be used for Events.
  ///
  /// It only receives the bare necessities for identifying in what room an
  /// Event is located. it receives a [Building] instance through [building]
  /// to populate the Building name in [Room._building]
  Room.forEvent({int UID, String code, Building building}){
    this._UID = UID;
    this._code = code;
    this._building = building.name;
  }

  /// Factory constructor for creating an instance from a [json] obtained from
  /// the API.
  ///
  /// The [Room._code] is created by combining the room code received
  /// by the API which contains only the number (most of the time) and the
  /// [Building._abbreviation] to create the full room code using
  /// [_createAbbreviation].
  /// It also uses [Utils.fixCapitalization] to fix the description and
  /// department from being in all caps.
  factory Room.fromJson(Map<String, dynamic> json, Building b) {
    return Room(
        json['rid'],
        _createAbbreviation(b.abbreviation, json['rcode']),
        b.name,
        json['rfloor'],
        Utils.fixCapitalization(json['rdescription']),
        Utils.fixCapitalization(json['rdept']),
        json['roccupancy'],
        json['rcustodian'],
        Coordinate.fromHJson(json)
    );
  }

  /// Factory constructor for creating an instance from a [json] obtained from
  /// the API, to be used for Events.
  ///
  /// The [Room._code] is created using [_createAbbreviation].
  factory Room.forEventFromJson(Map<String, dynamic> json) {
    Building b = Building.resultFromJson(json['building']);
    return Room.forEvent(
        UID: json['rid'],
        code: _createAbbreviation(b.abbreviation, json['rcode']),
        building: b
    );
  }

  /// Creates a correct [Room._code]
  ///
  /// This is done by combining the room code received from the API which
  /// contains only the number (most of the time) and the
  /// [Building._abbreviation] to create the full room code.
  static String _createAbbreviation(String buildingLetter, String code){
    // Checks if the room code from the API is in the form of "AAAA-####A"in
    // which case it just returns that as the API has a valid code.
    if(code.contains(RegExp(r"^\b[a-zA-Z]{1,4}-\d{1,4}[a-zA-Z]?$"))){
      return code;
    }
    // Checks if the room code from the API is in the form of "AAAA ####A"in
    // which case it just returns that with the "-"added.
    else if(code.contains(RegExp(r"^\b[a-zA-Z]{1,4} \d{1,4}[a-zA-Z]?$"))){
      var codeQuery = RegExp(
          r"(?<abrev>\b[a-zA-Z]{1,4})(?<space> )(?<code>\d{1,4}[a-zA-Z]?)")
          .firstMatch(code);
      return codeQuery.namedGroup("abrev")+"-"+ codeQuery.namedGroup("code");
    }
    // If the room code From the API is not in the correct form then we add the
    // building abbreviation and the "-" and return it.
    else {
      return buildingLetter + "-" + code;
    }
  }

  /// Unique identifier of this Room entity.
  /// It is represented in the API a "rid'.
  int get UID => _UID;

  /// The code assigned to this room by the university.
  /// It is represented in the API a "eid'.
  String get code => _code;

  /// The [Building._name] where this room is located in the campus.
  String get building => _building;

  /// The [Floor._floorNumber] where this room is located in the [Building].
  /// It is represented in the API a "rfloor'
  int get floor => _floor;

  /// A description of what this room is used for.
  /// It is represented in the API a "rdescription'
  String get description => _description;

  /// The department that this room belongs to in the campus
  /// It is represented in the API a "rdept'
  String get department => _department;

  /// Value used to identify how many people can occupy this room. Used
  /// mostly in classrooms and labs.
  /// It is represented in the API a "roccupancy'
  int get occupancy => _occupancy;

  /// The email of the person responsible for this room.
  /// It is represented in the API a "rcustodian'
  String get custodian => _custodianEmail;

  /// The GPS coordinates of this room
  Coordinate get coordinates => _coordinates;

  @override
  String toString() {
    return 'Room{_UID: $_UID, _code: $_code, _building: $_building, _floor: $_floor, _description: $_description, _department: $_department, _occupancy: $_occupancy, _custodian: $_custodianEmail, _coordinates: $_coordinates}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Room &&
              runtimeType == other.runtimeType &&
              _UID == other._UID;

  @override
  int get hashCode => _UID.hashCode;

}