
class Website {

  String _URL;
  String _description;
  Website(this._URL, this._description);

  factory Website.fromJson(Map<String, dynamic> json) {
    if(json == null){
      return null;
    }
    return Website(
        json['url'],
        json['wdescription']
    );
  }

  Map<String, dynamic> toJson() => {
    "url": _URL,
    "wdescription": _description,
  };

  static List<Website> jsonToList(List<dynamic> json){
    if(json == null){
      return null;
    }
    return new List.generate(json.length, (i) => Website.fromJson(json[i]));
  }

  static List<dynamic> toJsonList(List<Website> websites){
    if(websites == null){
      return null;
    }
    return new List.generate(websites.length, (i) => websites[i].toJson());
  }

  String get URL => _URL;
  String get description => _description;

  @override
  String toString() {
    return 'Website{_URL: $_URL, _description: $_description}';
  }
}