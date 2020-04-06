import 'package:InTheNou/models/coordinate.dart';

class Building {

  int _UID;
  String _abbreviation;
  String _name;
  String _commonName;
  int _numFloors;
  String _type;
  Coordinate _coordinates;
  String _image;

  Building.result({int UID, String abbreviation, String name,
    String commonName}){
    this._UID = UID;
    this._abbreviation = abbreviation;
    this._name = name;
    this._commonName = commonName;
  }

  Building(this._UID, this._abbreviation, this._name, this._commonName,
      this._numFloors, this._type, this._coordinates, this._image);
  //"building":{"babbrev":"S","bcommonname":"STEFANI","bid":1,"bname":"LUIS A STEFANI (INGENIERIA)","btype":"Acad\u00e9mico","distinctfloors":[1,2,3,4,5,6,7],"numfloors":7,"photourl":null

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      json['bid'],
      json['babbrev'],
      json['bname'],
      json['bcommonname'],
      json['numfloors'],
      json['btype'],
      json['bcoordinates'] ?? null,
      json['photourl'],
    );
  }

  factory Building.resultFromJson(Map<String, dynamic> json) {
    return Building.result(
      UID: json['bid'],
      abbreviation: json['babbrev'],
      name: json['bname'],
      commonName: json['bname'],
    );
  }

  int get UID => _UID;
  String get abbreviation => _abbreviation;
  String get name => _name;
  String get commonName => _commonName;
  int get numFloors => _numFloors;
  String get type => _type;
  Coordinate get coordinates => _coordinates;
  String get image => _image;

}