import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/coordinate.dart';

class Room {

  int _UID;
  String _code;
  String _building;
  int _floor;
  String _description;
  int _occupancy;
  String _custodian;
  Coordinate _coordinates;

  // "room":{},"raltitude":50.04,""rdept":"COMPUTER SCIENCE AND ENGINEERING","rlatitude":50.04,"rlongitude":50.04
  // not taking into account rdept and photourl
  Room(this._UID, this._code, this._building, this._floor, this._description,
      this._occupancy, this._custodian, this._coordinates);

  factory Room.fromJson(Map<String, dynamic> json, Building b) {
    return Room(
        json['rid'],
        b.abbreviation+"-"+json['rcode'],
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
        code: b.abbreviation+json['rcode'],
        building: b
    );
  }

  int get UID => _UID;
  String get code => _code;
  String get building => _building;
  int get floor => _floor;
  String get description => _description;
  int get occupancy => _occupancy;
  String get custodian => _custodian;
  Coordinate get coordinates => _coordinates;

}