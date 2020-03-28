import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/tag.dart';

class User {

  String _firstName;
  String _lastName;
  String _email;
  UserRole _role;
  List<Tag> _tags;
  UserPrivilege _userPrivilege;

  User(this._firstName, this._lastName, this._email, this._role, this._tags,
      this._userPrivilege);

  User.newUser(this._role, this._tags);

  User.copy(User user){
    this._firstName = user._firstName;
    this._lastName = user._lastName;
    this._email = user._email;
    this._role = user._role;
    this._tags = user._tags;
    this._userPrivilege = user._userPrivilege;
  }

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  UserRole get role => _role;
  List<Tag> get tags => _tags;
  UserPrivilege get userPrivilege => _userPrivilege;

  @override
  String toString() {
    return 'User{_firstName: $_firstName, _lastName: $_lastName, '
        '_email: $_email, _role: ${Utils.userRoleString(_role)}, '
        '_tags: $_tags, '
        '_userPrivilege: ${Utils.userPrivilegeString(_userPrivilege)}';
  }


}