
/// Object representation of a Website in the System
///
/// It contains the identifiable and descriptive properties of a Website
/// in our database.
///
/// {@category Model}
class Website {

  String _URL;
  String _description;

  /// The default constructor
  Website(this._URL, this._description);

  /// Factory constructor to create Website entities from [json] objects
  /// from the API.
  factory Website.fromJson(Map<String, dynamic> json) {
    if(json == null){
      return null;
    }
    return Website(
        json['url'],
        json['wdescription']
    );
  }

  /// Utility method to deserialize a Website from a JSON list passed through
  /// the parameter [json].
  static List<Website> jsonToList(List<dynamic> json){
    if(json == null){
      return List();
    }
    return new List.generate(json.length, (i) => Website.fromJson(json[i]));
  }

  /// Utility method to serialize a Website to JSON
  Map<String, dynamic> toJson() => {
    "url": _URL,
    "wdescription": _description.isEmpty ? null : _description,
  };

  /// Utility method to serialize a Website list passed through the parameter
  /// [websites] to a JSON list
  static List<dynamic> toJsonList(List<Website> websites){
    if(websites == null){
      return null;
    }
    return new List.generate(websites.length, (i) => websites[i].toJson());
  }

  /// The URL string of this Website.
  /// Is it represented in the API as part of "url'.
  String get URL => _URL;

  /// An optional Description of this website.
  /// Is it represented in the API as part of "wdescription'.
  String get description => _description;

  @override
  String toString() {
    return 'Website{_URL: $_URL, _description: $_description}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Website &&
              runtimeType == other.runtimeType &&
              _URL == other._URL;

  @override
  int get hashCode => _URL.hashCode;

}