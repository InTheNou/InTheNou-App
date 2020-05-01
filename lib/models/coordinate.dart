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

  /// Latitude property of the GPS Coordinate.
  /// It is represented in the API a "rlatitude'.
  double _lat;

  /// Longitude property of the GPS Coordinate.
  /// It is represented in the API a "rlongitude'.
  double _long;

  /// Altitude property of the GPS Coordinate.
  /// It is represented in the API a "raltitude'.
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

  double get lat => _lat;
  double get long => _long;
  double get alt => _alt;

  @override
  String toString() {
    return 'Coordinate{_lat: $_lat, _long: $_long, _alt: $_alt}';
  }

}