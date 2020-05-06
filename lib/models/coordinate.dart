import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/user.dart';

/// Object representation of GPS Coordinates in the System.
///
/// These are used to locate [Building], [Room], [Event], and [User].
///
/// {@category Model}
class Coordinate {

  double _lat;
  double _long;
  double _alt;

  /// Default constructor for GPS Coordinates
  Coordinate(this._lat, this._long, this._alt);

  /// Factory constructor to create GPS Coordinate entities from json objects
  /// from the API.
  factory Coordinate.fromHJson(Map<String,dynamic> json){
    return Coordinate(
      json['rlatitude'],
      json['rlongitude'],
      json['raltitude']
    );
  }

  /// Latitude property of the GPS Coordinate.
  /// It is represented in the API a "rlatitude'.
  double get lat => _lat;

  /// Longitude property of the GPS Coordinate.
  /// It is represented in the API a "rlongitude'.
  double get long => _long;

  /// Altitude property of the GPS Coordinate.
  /// It is represented in the API a "raltitude'.
  double get alt => _alt;

  @override
  String toString() {
    return 'Coordinate{_lat: $_lat, _long: $_long, _alt: $_alt}';
  }

}