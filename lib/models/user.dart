import 'package:InTheNou/models/tag.dart';

class User {

  String _firstName;
  String _lastName;
  String _email;
  String _type;
  List<Tag> _tags;

  User(this._firstName, this._lastName, this._email, this._type, this._tags);

  User.nea(this._firstName, this._lastName, this._email);


}