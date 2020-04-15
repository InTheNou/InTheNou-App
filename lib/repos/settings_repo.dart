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


  Future<int> changeRecommendationTime(int time) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(RECOMMENDATION_INTERVAL_KEY, time)
        .then((success) => time);
  }
  Future<int> changeSmartNotificationTime(int time) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(SMART_INTERVAL_KEY, time)
        .then((success) => time);
  }
  Future<int> changeCancellationTime(int time) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(CANCELLATION_INTERVAL_KEY, time)
        .then((success) => time);
  }
  Future<bool> changeRecommendationDebug(bool toggle) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool(RECOMMENDATION_DEBUG_KEY, toggle)
        .then((success) => toggle);
  }

  Future<int> getRecommendationTime() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getInt(RECOMMENDATION_INTERVAL_KEY);
  }
  Future<bool> getRecommendationDebug() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(RECOMMENDATION_DEBUG_KEY);
  }

  Future<int> getSmartNotificationTime() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getInt(SMART_INTERVAL_KEY);
  }

  Future<int> getCancellationTime() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getInt(CANCELLATION_INTERVAL_KEY);
  }
}