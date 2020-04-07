import 'package:InTheNou/assets/utils.dart';

class Floor {

  String _floorName;
  int _floorNumber;
  Floor(this._floorName, this._floorNumber);

  factory Floor.fromJson(int json){
    return Utils.ordinalNumber(json);
  }

  static List<Floor> fromJsonToList(List<dynamic> json){
    if(json == null){
      return null;
    }
    return List.generate(json.length, (i) => Floor.fromJson(int.parse(json[i].toString())));
  }

  String get floorName => _floorName;
  int get floorNumber => _floorNumber;

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