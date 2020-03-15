import 'package:InTheNou/models/coordinate.dart';

class Building {

  int _UID;
  String _name;
  String _commonName;
  int _numFloors;
  String _type;
  Coordinate _coordinates;

  Building.result(this._UID, this._name, this._commonName);

  Building(this._UID, this._name, this._commonName, this._numFloors, this._type,
      this._coordinates);

}