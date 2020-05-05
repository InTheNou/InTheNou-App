import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/building.dart';


/// Object representation of a Floor of a [Building] in the System
///
/// This is more of a utility model to easily show floors in the ui and
/// manipulate floor selections.
///
/// {@category Model}
class Floor {

  String _floorName;
  int _floorNumber;

  /// Default constructor
  Floor(this._floorName, this._floorNumber);

  /// Factory constructor for creating an instance from a [json] obtained from
  /// the API.
  ///
  /// It users [Utils.ordinalNumber] to create the proper [_floorName] from
  /// the [_floorNumber].
  factory Floor.fromJson(int json){
    return Utils.ordinalNumber(json);
  }

  /// Factory constructor for creating a list of floors from a [json] list
  /// obtained from the API server.
  ///
  /// Uses the more basic [Floor.fromJson] to create the instances.
  static List<Floor> fromJsonToList(List<dynamic> json){
    if(json == null){
      return null;
    }
    return List.generate(json.length, (i) => Floor.fromJson(int.parse(json[i].toString())));
  }

  /// Dynamic name created for a given floor int he for of "#th Floor"
  String get floorName => _floorName;

  /// The actual number of the floor, can be from 0 or 1 depending  on the
  /// building
  int get floorNumber => _floorNumber;


  @override
  String toString() {
    return 'Floor{_floorName: $_floorName, _floorNumber: $_floorNumber}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Floor &&
              runtimeType == other.runtimeType &&
              _floorName == other._floorName &&
              _floorNumber == other._floorNumber;

  @override
  int get hashCode =>
      _floorName.hashCode ^
      _floorNumber.hashCode;

}