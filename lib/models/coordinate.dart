
class Coordinate {

  double _lat;
  double _long;

  Coordinate(this._lat, this._long);

  double get lat => _lat;
  double get long => _long;

  @override
  String toString() {
    return 'Coordinate{_lat: $_lat, _long: $_long}';
  }

}