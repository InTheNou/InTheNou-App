
class Tag {

  int _UID;
  String _name;
  int _weight;

  Tag(this._UID, this._name, this._weight);

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

  Map<String, dynamic> toJson() => {
    "tid": _UID,
    "tname": _name,
    "tagweight": _weight
  };

  Map<String, dynamic> toSmallJson() => {
    "tid": _UID,
  };

  static List<Tag> fromJsonToList(List<dynamic> json){
    if(json == null){
      return null;
    }
    return new List.generate(json.length, (i) => Tag.fromJson(json[i]));
  }

  static List<Map<String, dynamic>> toJsonList(List<Tag> tags) {
    if(tags == null){
      return null;
    }
    return new List.generate(tags.length, (i) => tags[i].toJson());
  }

  static List<Map<String, dynamic>> toSmallJsonList(List<Tag> tags) {
    if(tags == null){
      return null;
    }
    return new List.generate(tags.length, (i) => tags[i].toSmallJson());
  }

  int get UID => _UID;
  String get name => _name;
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