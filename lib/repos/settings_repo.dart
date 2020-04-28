import 'package:InTheNou/assets/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@category Repo}
class SettingsRepo {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static final SettingsRepo _instance = SettingsRepo._internal();

  factory SettingsRepo() {
    return _instance;
  }

  SettingsRepo._internal();

  /// Updates the local Default Notification time setting
  Future<int> changeDefaultNotificationTime(int time) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(DEFAULT_NOTIFICATION_KEY, time)
        .then((success) => time);
  }

  /// Updates the local Smart Notification toggle setting
  Future<bool> toggleSmartNotification(bool toggle) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool(SMART_NOTIFICATION_KEY, toggle)
        .then((success) => toggle);
  }

  /// Gets the local Default Notification time setting
  Future<int> getDefaultNotificationTime() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getInt(DEFAULT_NOTIFICATION_KEY);
  }

  /// Gets the local Smart Notification toggle setting
  Future<bool> getSmartNotificationToggle() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(SMART_NOTIFICATION_KEY);
  }

  //Debug settings

  /// Updates the local Recommendation time setting
  Future<int> changeRecommendationTime(int time) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(RECOMMENDATION_INTERVAL_KEY, time)
        .then((success) => time);
  }

  /// Gets the local Recommendation time setting
  Future<int> getRecommendationTime() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getInt(RECOMMENDATION_INTERVAL_KEY);
  }

  /// Gets the local Recommendation time setting
  ///
  /// Currently not implemented to be used
  Future<int> changeSmartNotificationTime(int time) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(SMART_INTERVAL_KEY, time)
        .then((success) => time);
  }

  /// Get the local Smart Notification Time Setting
  ///
  /// Currently not implemented to be used
  Future<int> getSmartNotificationTime() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getInt(SMART_INTERVAL_KEY);
  }

  /// Updates the local Cancellation time setting
  Future<int> changeCancellationTime(int time) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(CANCELLATION_INTERVAL_KEY, time)
        .then((success) => time);
  }

  /// Gets the local Cancellation time setting
  Future<int> getCancellationTime() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getInt(CANCELLATION_INTERVAL_KEY);
  }

  /// Updates the local Recommendation Debug Notification toggle setting
  Future<bool> changeRecommendationDebug(bool toggle) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool(RECOMMENDATION_DEBUG_KEY, toggle)
        .then((success) => toggle);
  }

  /// Gets the local Recommendation Debug Notification toggle setting
  Future<bool> getRecommendationDebug() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(RECOMMENDATION_DEBUG_KEY);
  }


}