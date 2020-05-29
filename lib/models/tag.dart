import 'package:InTheNou/models/event.dart';

/// Object representation of a Tag in the System
///
/// Tags are topics that describe and [Event]. They are used when an event is
/// created to define what that event is about. It is also used to define
/// what a user is interested in so that events can be recommended to them.
///
/// {@category Model}
class Tag {

  int _UID;
  String _name;
  int _weight;

  /// The default constructor
  Tag(this._UID, this._name, this._weight);

  /// Factory constructor to create Tag entities from json objects
  /// from the API.
  factory Tag.fromJson(Map<String, dynamic> json) {
    if(json == null){
      return null;
    }
    return Tag(
        json['tid'],
        json['tname'],
        json["tagweight"] ?? 0
    );
  }

  /// Utility method to deserialize a List Tags received as a [json] list
  /// from the API.
  static List<Tag> fromJsonToList(List<dynamic> json){
    if(json == null){
      return null;
    }
    return new List.generate(json.length, (i) => Tag.fromJson(json[i]));
  }

  /// Utility method to serialize a Tag to JSON
  Map<String, dynamic> toJson() => {
    "tid": _UID,
    "tname": _name,
    "tagweight": _weight
  };

  /// Utility method to serialize a Tag to JSON, only including the [Tag._UID]
  Map<String, dynamic> toSmallJson() => {
    "tid": _UID,
  };

  /// Utility method to serialize a list of Tags to a JSON list
  static List<Map<String, dynamic>> toJsonList(List<Tag> tags) {
    if(tags == null){
      return null;
    }
    return new List.generate(tags.length, (i) => tags[i].toJson());
  }

  /// Utility method to serialize a list of Tags to a JSON list, only
  /// including the [Tag._UID]
  static List<Map<String, dynamic>> toSmallJsonList(List<Tag> tags) {
    if(tags == null){
      return null;
    }
    return new List.generate(tags.length, (i) => tags[i].toSmallJson());
  }


  /// Unique identifier of this Service entity.
  /// It is represented in the API a "tid'.
  int get UID => _UID;

  /// The given name of this Service entity.
  /// It is represented in the API a "tname'.
  String get name => _name;

  /// The current wait of the user interest in this tag.
  /// It is represented in the API a "tagweight'.
  int get weight => _weight;

  @override
  String toString() {
    return 'Tag{_UID: $_UID, _name: $_name, _weight: $_weight}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Tag &&
              runtimeType == other.runtimeType &&
              _UID == other._UID;

  @override
  int get hashCode => _UID.hashCode;

}