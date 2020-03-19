class Website {

  String _URL;
  String _description;
  Website(this._URL, this._description);

  String get URL => _URL;
  String get description => _description;

  @override
  String toString() {
    return 'Website{_URL: $_URL, _description: $_description}';
  }
}