import 'package:flutter_flux/flutter_flux.dart' as flux;

class UserStore extends flux.Store{

  UserStore() {

  }
}

final flux.StoreToken UserToken = new flux.StoreToken(new UserStore());