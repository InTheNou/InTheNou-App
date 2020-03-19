class Tag {

  String _name;
  int _weight;

  Tag(this._name, this._weight);

  String get name => _name;
  int get weight => _weight;

  @override
  String toString() {
    return 'Tag{_name: $_name, _weight: $_weight}';
  }

}