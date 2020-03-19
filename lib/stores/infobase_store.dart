import 'package:InTheNou/models/building.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/repos/infobase_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class InfoBaseStore extends flux.Store{

  List<Building> _buildings;
  List<Room> _roomsInBuilding;

  InfoBaseRepo _infobaseRepo;

  InfoBaseStore() {

  }

}

final flux.StoreToken infoBaseToken = new flux.StoreToken(new InfoBaseStore());