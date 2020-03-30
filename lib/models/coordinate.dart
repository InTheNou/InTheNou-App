
class Coordinate {

  double _lat;
  double _long;
  double _alt;

  Coordinate(this._lat, this._long);

  double get lat => _lat;
  double get long => _long;
  double get alt => _alt;

  @override
  String toString() {
    return 'Coordinate{_lat: $_lat, _long: $_long, _alt: $_alt}';
  }

}