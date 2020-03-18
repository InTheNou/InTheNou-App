import 'package:InTheNou/assets/values.dart';

class PhoneNumber {

  String _number;
  PhoneType _type;

  PhoneNumber(this._number, this._type);

  String get number => _number;
  PhoneType get type => _type;

}