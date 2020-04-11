import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/floor.dart';

class Building {

  int _UID;
  String _abbreviation;
  String _name;
  String _commonName;
  int _numFloors;
  List<Floor> _floors;
  String _type;
  Coordinate _coordinates;
  String _image;

  Building.result({int UID, String abbreviation, String name,
    String commonName, String image}){
    this._UID = UID;
    this._abbreviation = abbreviation;
    this._name = name;
    this._commonName = commonName;
    this._image = image;
  }

  Building(this._UID, this._abbreviation, this._name, this._commonName,
      this._numFloors, this._floors, this._type, this._coordinates, this
          ._image);

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      json['bid'],
      json['babbrev'],
      json['bname'].trim(),
      json['bcommonname'] ?? "error",
      json['numfloors'],
      Floor.fromJsonToList(json['distinctfloors']),
      json['btype'],
      Coordinate.fromHJson({
        "CLatitude" : json['CLatitude'],
        "CLongitude" : json['CLongitude'],
        "CAltitude" : json['CAltitude'],
      }),
      json['photourl'],
    );
  }
  factory Building.resultFromJson(Map<String, dynamic> json) {
    return Building.result(
      UID: json['bid'],
      abbreviation: json['babbrev'],
      name: json['bname'],
      commonName: json['bcommonname'],
      image: json['photourl'],
    );
  }

  int get UID => _UID;
  String get abbreviation => _abbreviation;
  String get name => _name;
  String get commonName => _commonName;
  int get numFloors => _numFloors;
  List<Floor> get floors => _floors;
  String get type => _type;
  Coordinate get coordinates => _coordinates;
  String get image => _image;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Building &&
              runtimeType == other.runtimeType &&
              _UID == other._UID;

  @override
  int get hashCode => _UID.hashCode;



}