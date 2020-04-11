import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';

class PhoneNumber {

  String _number;
  PhoneType _type;

  PhoneNumber(this._number, this._type);

  factory PhoneNumber.fromJson(Map<String, dynamic> json) {
    if(json == null){
      return null;
    }
    return PhoneNumber(
        json['pnumber'],
        Utils.telephoneTypeFromString(json['ptype'])
    );
  }

  static List<PhoneNumber> jsonToList(List<dynamic> json){
    if(json == null){
      return List();
    }
    return new List.generate(json.length, (i) => PhoneNumber.fromJson(json[i]));
  }

  String get number => _number;
  PhoneType get type => _type;

}