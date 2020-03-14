import 'package:flutter_flux/flutter_flux.dart' as flux;

class InfoBaseStore extends flux.Store{

  InfoBaseStore() {

  }

}

final flux.StoreToken infoBaseToken = new flux.StoreToken(new InfoBaseStore());