import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/background/notification_handler.dart';
import 'package:InTheNou/repos/settings_repo.dart';
import 'package:InTheNou/repos/user_repo.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:package_info/package_info.dart';

class SettingsStore extends flux.Store {

  int _defaultNotificationTime;
  bool _smartNotificationEnabled;

  int _recommendationInterval;
  int _smartInterval;
  int _cancellationInterval;
  bool _recommendationDebug;

  PackageInfo packageInfo;

  SettingsRepo _settingsRepo = new SettingsRepo();
  UserRepo _userRepo = new UserRepo();

  SettingsStore() {
    PackageInfo.fromPlatform().then((value) {
      packageInfo = value;
    });

    _settingsRepo.getDefaultNotificationTime().then((value) {
      _defaultNotificationTime = value;
    });
    _settingsRepo.getSmartNotificationToggle().then((value) {
      _smartNotificationEnabled = value;
    });
    triggerOnAction(refreshSettings, (_) {
      _settingsRepo.getDefaultNotificationTime().then((value) {
        _defaultNotificationTime = value;
      });
      _settingsRepo.getSmartNotificationToggle().then((value) {
        _smartNotificationEnabled = value;
      });
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

    triggerOnConditionalAction(changeRecommendationIntervalAction, (int time) {
      return _settingsRepo.changeRecommendationTime(time).then((value){
        _recommendationInterval = value;
        return true;
      });
    });
    triggerOnConditionalAction(changeSmartIntervalAction, (int time) {
      return _settingsRepo.changeSmartNotificationTime(time).then((value){
        _smartInterval = value;
        return true;
      });
    });
    triggerOnConditionalAction(changeCancellationIntervalAction, (int time) {
      return _settingsRepo.changeCancellationTime(time).then((value){
        _cancellationInterval = value;
        return true;
      });
    });
    triggerOnConditionalAction(changeRecommendationDebugAction, (bool toggle) {
      return _settingsRepo.changeRecommendationDebug(toggle).then((value){
        _recommendationDebug = value;
        return true;
      });
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

  Future<int> get recommendationInterval  async {
    return _recommendationInterval ??
        _settingsRepo.getRecommendationTime();
  }
  Future<int> get smartInterval async{
    return _smartInterval ??
        _settingsRepo.getSmartNotificationTime();
  }
  Future<int> get cancellationInterval  async {
    return _cancellationInterval ??
        _settingsRepo.getCancellationTime();
  }
  Future<bool> get recommendationDebug async{
    return _recommendationDebug ??
        _settingsRepo.getRecommendationDebug();
  }
}

final flux.Action refreshSettings = new flux.Action();

final flux.Action<int> changeNotificationTimeAction = new flux.Action();
final flux.Action<bool> toggleSmartAction = new flux.Action();
final flux.Action logoutAction = new flux.Action();

final flux.Action<int> changeRecommendationIntervalAction = new flux.Action();
final flux.Action<int> changeSmartIntervalAction = new flux.Action();
final flux.Action<int> changeCancellationIntervalAction = new flux.Action();
final flux.Action<bool> changeRecommendationDebugAction = new flux.Action();


final flux.StoreToken settingsStoreToken = new flux.StoreToken(
    new SettingsStore());