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

  Room(this._UID, this._code, this._building, this._floor, this._description,
      this._occupancy, this._custodian, this._coordinates);

  Room.result(this._UID, this._code, this._building, this._description);

}