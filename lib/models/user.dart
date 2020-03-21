import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/tag.dart';

class User {

  String _firstName;
  String _lastName;
  String _email;
  String _type;
  List<Tag> _tags;
  UserPrivilege _userPrivilege;

  User(this._firstName, this._lastName, this._email, this._type, this._tags,
      this._userPrivilege);

  User.newUser(this._firstName, this._lastName, this._email);

  User.copy(User user){
    this._firstName = user._firstName;
    this._lastName = user._lastName;
    this._email = user._email;
    this._type = user._type;
    this._tags = user._tags;
    this._userPrivilege = user._userPrivilege;
  }

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get type => _type;
  List<Tag> get tags => _tags;
  UserPrivilege get userPrivilege => _userPrivilege;


}