import 'package:flutter_flux/flutter_flux.dart' as flux;

class EventCreationStore extends flux.Store {

  EventCreationStore() {

  }

}

final flux.StoreToken EventCreationStoreToken = new flux.StoreToken(
    new EventCreationStore());