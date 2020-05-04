import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/tag.dart';

/// Object representation of an User in the System
///
/// It contains the identifiable and descriptive properties of a User
/// in our database.
///
/// {@category Model}
class User {

  int _UID;
  String _firstName;
  String _fullName;
  String _email;
  UserRole _role;
  List<Tag> _tags;
  UserPrivilege _userPrivilege;
  String photo;

  /// The Default constructor
  User(this._UID, this._firstName, this._fullName, this._email, this._role,
      this._tags, this._userPrivilege, this.photo);

  /// Factory constructor to create a User  from a [json] object
  /// from the API.
  ///
  /// Users [Utils.userRoleFromString] to translate the role representation
  /// in the database to a [UserRole]. Also uses [Utils.userPrivilegeFromInt]
  /// to translate the privilege representation in the database to a
  /// [UserPrivilege].
  factory User.fromJson(Map<String,dynamic> json){
    return User(
        json["uid"],
        json["display_name"].toString().split(" ")[0],
        json["display_name"],
        json["email"],
        Utils.userRoleFromString(json["type"]),
        null,
        Utils.userPrivilegeFromInt(json["roleid"] as int),
        json["photo"]
    );
  }

  /// Utility method to serialize a User to JSON
  Map<String,dynamic> toJson(){
    return {
      "uid" : _UID,
      "first_name" : _firstName,
      "display_name" : _fullName,
      "email" : _email,
      "type" : Utils.userRoleString(_role),
      "tags" : Tag.toJsonList(_tags),
      "roleid" : Utils.userPrivilegeKey(_userPrivilege),
      "photo" : photo
    };
  }

  /// Unique identifier of this User in the database.
  /// It is represented in the API a "uid'.
  int get UID => _UID;

  /// The first name of this User in the database.
  /// Is it represented in the API as part of "display_name'.
  String get firstName => _firstName;

  /// The full name of this User in the database.
  /// Is it represented in the API as "display_name'.
  String get fullName => _fullName;

  /// The email associated with this User in the database.
  /// Is it represented in the API as "email'.
  String get email => _email;

  /// The assigned [UserRole] to this user.
  /// Is it represented in the API as "type'.
  UserRole get role => _role;

  /// The selected and developed interest [Tags]s associated with this User.
  /// Is it represented in the API as "tags'.
  List<Tag> get tags => _tags;
  set tags(List<Tag> value) {
    _tags = value;
  }

  /// The email associated with this User in the database.
  /// Is it represented in the API as part of "roleid'.
  UserPrivilege get userPrivilege => _userPrivilege;
  set userPrivilege(UserPrivilege value) {
    _userPrivilege = value;
  }

  @override
  String toString() {
    return 'User{_UID: $_UID, _firstName: $_firstName, _fullName: $_fullName, _email: $_email, _role: $_role, _tags: $_tags, _userPrivilege: $_userPrivilege, photo: $photo}';
  }
}