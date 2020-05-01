import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:InTheNou/models/room.dart';

/// Object representation of a Building in the System.
///
/// It contains the identifiable and descriptive properties of the Building
/// entity in our database.
///
/// {@category Model}
class Building {

  /// Unique identifier of this Building entity.
  /// It is represented in the API a "bid'.
  int _UID;

  /// The abbreviation of the building entity used for [Room.code].
  /// Is it represented in the API as "babbrev'
  String _abbreviation;

  /// The name of the building entity.
  /// Is it represented in the API as "bname'
  String _name;

  /// A common name used to associate the building entity.
  /// Is it represented in the API as "bcommonname'
  String _commonName;

  /// The number of floors this building entity has.
  /// Is it represented in the API as "numfloors'
  int _numFloors;

  /// A list of [Floor]s inside this building entity,
  /// Is it represented in the API as "distinctfloors'
  List<Floor> _floors;

  /// A descriptive property of this building entity.
  /// Is it represented in the API as "btype'
  String _type;

  /// An optional image URL associated with this building entity.
  /// Is it represented in the API as "photourl'
  String _image;

  /// Default constructor for any building entity
  Building(this._UID, this._abbreviation, this._name, this._commonName,
      this._numFloors, this._floors, this._type, this._image);

  /// Constructor used for when showing Building entities as a list. This
  /// constructor only uses the bare minimum properties.
  Building.result({int UID, String abbreviation, String name,
    String commonName, String image}){
    this._UID = UID;
    this._abbreviation = abbreviation;
    this._name = name;
    this._commonName = commonName;
    this._image = image;
  }

  /// Factory constructor to create Building entities from json objects
  /// from the API.
  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      json['bid'],
      json['babbrev'],
      Utils.fixCapitalization(json['bname']),
      Utils.fixCapitalization(json['bcommonname']),
      json['numfloors'],
      Floor.fromJsonToList(json['distinctfloors']),
      json['btype'],
      json['photourl'],
    );
  }

  /// Factory constructor to create Building entities from json objects
  /// from the API, using the Result constructor.
  factory Building.resultFromJson(Map<String, dynamic> json) {
    return Building.result(
      UID: json['bid'],
      abbreviation: json['babbrev'],
      name: Utils.fixCapitalization(json['bname']),
      commonName: Utils.fixCapitalization(json['bcommonname']),
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