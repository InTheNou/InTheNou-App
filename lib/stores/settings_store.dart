import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/repos/settings_repo.dart';
import 'package:InTheNou/repos/user_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

class SettingsStore extends flux.Store {

  int _defaultNotificationTime;
  bool _smartNotificationEnabled;


  SettingsRepo _settingsRepo = new SettingsRepo();
  UserRepo _userRepo = new UserRepo();

  SettingsStore() {
    _settingsRepo.getDefaultNotificationTime().then((value) {
      _defaultNotificationTime = value;
    });
    _settingsRepo.getSmartNotificationToggle().then((value) {
      _smartNotificationEnabled = value;
    });
    triggerOnConditionalAction(changeNotificationTimeAction, (int time) {
      return _settingsRepo.changeDefaultNotificationTime(time).then((value){
        _defaultNotificationTime = value;
        return true;
      });
    });
    triggerOnConditionalAction(toggleSmartAction, (bool toggle) {
      return _settingsRepo.toggleSmartNotification(toggle).then((value){
        _smartNotificationEnabled = toggle;
        if(toggle == false){
          NotificationHandler.cancelAllSmartNotifications();
        }
        return true;
      });
    });
    triggerOnConditionalAction(logoutAction, (_) async{
      await _userRepo.logOut();
      return false;
    });
  }

  Future<int> get defaultNotificationTime  async {
    return _defaultNotificationTime ??
        _settingsRepo.getDefaultNotificationTime();
  }
  Future<bool> get smartNotificationEnabled async{
    return _smartNotificationEnabled ??
        _settingsRepo.getSmartNotificationToggle();
  }
  List<int> get defaultTimes => defaultNotificationTimes;

}

final flux.Action<int> changeNotificationTimeAction = new flux.Action();
final flux.Action<bool> toggleSmartAction = new flux.Action();
final flux.Action logoutAction = new flux.Action();

final flux.StoreToken settingsStoreToken = new flux.StoreToken(
    new SettingsStore());