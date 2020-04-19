import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/service.dart';

class Room {

  int _UID;
  String _code;
  String _building;
  int _floor;
  String _description;
  int _occupancy;
  String _custodian;
  Coordinate _coordinates;
  List<Service> services;

  // "room":{},"raltitude":50.04,""rdept":"COMPUTER SCIENCE AND ENGINEERING","rlatitude":50.04,"rlongitude":50.04
  // not taking into account rdept and photourl
  Room(this._UID, this._code, this._building, this._floor, this._description,
      this._occupancy, this._custodian, this._coordinates);

  factory Room.fromJson(Map<String, dynamic> json, Building b) {
    return Room(
        json['rid'],
        _createAbbreviation(b.abbreviation, json['rcode']),
        b.name,
        json['rfloor'],
        json['rdescription'],
        json['roccupancy'],
        json['rcustodian'],
        Coordinate.fromHJson(json)
    );
  }

  Room.result(this._UID, this._code, this._building, this._description);

  Room.forEvent({int UID, String code, Building building}){
    this._UID = UID;
    this._code = code;
    this._building = building.name;
  }

  factory Room.forEventFromJson(Map<String, dynamic> json) {
    Building b = Building.resultFromJson(json['building']);
    return Room.forEvent(
        UID: json['rid'],
        code: _createAbbreviation(b.abbreviation, json['rcode']),
        building: b
    );
  }

  static String _createAbbreviation(String buildingLetter, String code){
    if(code.contains(RegExp(r"^\b[a-zA-Z]{1,2}-\d{1,3}[a-zA-Z]?$"))){
      return code;
    } else if(code.contains(RegExp(r"^\b[a-zA-Z]{1,2} \d{1,3}[a-zA-Z]?$"))){
      var codeQuery = RegExp(
          r"(?<abrev>\b[a-zA-Z]{1,2})(?<space> )(?<code>\d{1,3}[a-zA-Z]?)")
          .firstMatch(code);
      return codeQuery.namedGroup("abrev")+"-"+ codeQuery.namedGroup("code");
    } else {
      return buildingLetter + "-" + code;
    }
  }

  int get UID => _UID;
  String get code => _code;
  String get building => _building;
  int get floor => _floor;
  String get description => _description;
  int get occupancy => _occupancy;
  String get custodian => _custodian;
  Coordinate get coordinates => _coordinates;


  @override
  String toString() {
    return 'Room{_UID: $_UID, _code: $_code, _building: $_building, _floor: $_floor, _description: $_description, _occupancy: $_occupancy, _custodian: $_custodian, _coordinates: $_coordinates, services: $services}';
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