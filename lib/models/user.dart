import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/tag.dart';

class User {

  int _UID;
  String _firstName;
  String _fullName;
  String _email;
  UserRole _role;
  List<Tag> _tags;
  UserPrivilege _userPrivilege;
  String photo;

  User(this._UID, this._firstName, this._fullName, this._email, this._role,
      this._tags, this._userPrivilege);

  factory User.fromJson(Map<String,dynamic> json){
    return User(
        json["uid"],
        json["display_name"].toString().split(" ")[0],
        json["display_name"],
        json["email"],
        Utils.userRoleFromString(json["type"]),
        null,
        Utils.userPrivilegeFromInt(json["roleid"] as int));
  }

  Map<String,dynamic> toJson(){
    return {
      "uid" : _UID,
      "first_name" : _firstName,
      "display_name" : _fullName,
      "email" : _email,
      "type" : Utils.userRoleString(_role),
      "tags" : Tag.toJsonList(_tags),
      "roleid" : Utils.userPrivilegeKey(_userPrivilege)
    };
  }

  int get UID => _UID;
  String get firstName => _firstName;
  String get fullName => _fullName;
  String get email => _email;
  UserRole get role => _role;
  List<Tag> get tags => _tags;
  UserPrivilege get userPrivilege => _userPrivilege;

  set tags(List<Tag> value) {
    _tags = value;
  }

  set userPrivilege(UserPrivilege value) {
    _userPrivilege = value;
  }

  @override
  String toString() {
    return 'User{_UID: $_UID, _firstName: $_firstName, _fullName: $_fullName, _email: $_email, _role: $_role, _tags: $_tags, _userPrivilege: $_userPrivilege}';
  }


}