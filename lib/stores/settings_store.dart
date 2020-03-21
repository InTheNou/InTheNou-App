import 'package:flutter_flux/flutter_flux.dart' as flux;

class SettingsStore extends flux.Store {

  SettingsStore() {

  }

}

final flux.StoreToken SettingsStoreToken = new flux.StoreToken(
    new SettingsStore());