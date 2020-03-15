import 'package:flutter_flux/flutter_flux.dart' as flux;


class EventFeedStore extends flux.Store{

  EventFeedStore() {

  }

}


final flux.Action<int> increment = new flux.Action<int>();
final flux.StoreToken eventFeedToken = new flux.StoreToken(new EventFeedStore
  ());