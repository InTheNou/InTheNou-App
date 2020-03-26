import 'package:InTheNou/assets/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepo {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static final SettingsRepo _instance = SettingsRepo._internal();

  factory SettingsRepo() {
    return _instance;
  }

  SettingsRepo._internal();

  Future<int> changeDefaultNotificationTime(int time) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(DEFAULT_NOTIFICATION_KEY, time)
        .then((success) => time);
  }

  Future<bool> toggleSmartNotification(bool toggle) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool(SMART_NOTIFICATION_KEY, toggle)
        .then((success) => toggle);
  }

  Future<int> getDefaultNotificationTime() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getInt(DEFAULT_NOTIFICATION_KEY);
  }

  Future<bool> getSmartNotificationToggle() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(SMART_NOTIFICATION_KEY);
  }
}