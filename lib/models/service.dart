import 'package:InTheNou/models/phone_number.dart';
import 'package:InTheNou/models/website.dart';

class Service {

  int _UID;
  String _name;
  String _description;
  String _roomCode;
  String _schedule;
  List<PhoneNumber> _numbers;
  List<Website> _websites;

  Service(this._UID, this._name, this._description, this._roomCode,
      this._schedule, this._numbers, this._websites);

  Service.name(this._UID, this._name, this._description, this._roomCode);

  int get UID => _UID;
  String get name => _name;
  String get description => _description;
  String get roomCode => _roomCode;
  String get schedule => _schedule;
  List<PhoneNumber> get numbers => _numbers;
  List<Website> get websites => _websites;

}