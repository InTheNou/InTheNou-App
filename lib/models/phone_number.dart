import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';


/// Object representation of a phone number in the System
///
/// {@category Model}
class PhoneNumber {

  String _number;
  PhoneType _type;

  /// Default constructor
  PhoneNumber(this._number, this._type);

  /// Factory constructor for creating an instance from [json] obtained from
  /// the API.
  factory PhoneNumber.fromJson(Map<String, dynamic> json) {
    if(json == null){
      return null;
    }
    return PhoneNumber(
        json['pnumber'],
        Utils.telephoneTypeFromString(json['ptype'])
    );
  }

  /// Factory constructor for creating a list of Phones from a [json] list
  /// obtained from the API server.
  ///
  /// Uses the more basic [PhoneNumber.fromJson] to create the instances.
  static List<PhoneNumber> jsonToList(List<dynamic> json){
    if(json == null){
      return List();
    }
    return new List.generate(json.length, (i) => PhoneNumber.fromJson(json[i]));
  }

  /// It containes the phone number correctly formatted as a string
  /// "###-=###-####" for [PhoneType.M] (Mobile), [PhoneType.L] (Land-line) and
  /// [PhoneType.F] (Fax). OR "###-###-####,####"for [PhoneType.E] (Extension).
  /// It is represented in the API a "pnumber'
  String get number => _number;

  /// The type of Phone number between Mobile, Land-line, Fax and Extension.
  /// It is represented in the API a "ptype'
  PhoneType get type => _type;

}