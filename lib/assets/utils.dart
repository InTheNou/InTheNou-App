import 'dart:math';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {

  static String feedTypeString(FeedType feedType) =>
      feedType == FeedType.PersonalFeed ? "PersonalFeed" : "GeneralFeed";

  static String infoBaseSearchString(InfoBaseSearchType type) =>
      type == InfoBaseSearchType.Building ? "Buildings Search" :
      type == InfoBaseSearchType.Room ? "Rooms Search" : "Services Search";

  static String telephoneTypeString(PhoneType telephoneType) =>
      telephoneType == PhoneType.E ? "E" :
      telephoneType == PhoneType.F ? "F" :
      telephoneType == PhoneType.L ? "L" : "M";

  static String userPrivilegeString(UserPrivilege type) =>
      type == UserPrivilege.User ? "User" :
      type == UserPrivilege.EventCreator ? "Event Creator" :
      type == UserPrivilege.Moderator ? "Moderator" : "Administrator";

  static String userRoleString(UserRole type) =>
      type == UserRole.Student ? "Student" :
      type == UserRole.TeachingPersonnel ? "Teaching Personnel" :
      "Non Teaching Personnel";

  static String notificationTypeString(NotificationType type) =>
      type == NotificationType.SmartNotification ? "SmartNotification" :
      type == NotificationType.DefaultNotification ? "DefaultNotification" :
      "RecommendationNotification";

  static NotificationType notificationTypeFromString(String type) =>
      type == "SmartNotification" ? NotificationType.SmartNotification :
      type == "DefaultNotification" ? NotificationType.DefaultNotification :
      NotificationType.RecommendationNotification;

  ///  Check if shared preferences has been setup, if not then set the default
  /// values
  static Future<void> checkSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey(DEFAULT_NOTIFICATION_KEY)){
      prefs.setInt(DEFAULT_NOTIFICATION_KEY, DEFAULT_NOTIFICATION_TIME);
    }
    if(!prefs.containsKey(SMART_NOTIFICATION_KEY)) {
      prefs.setBool(SMART_NOTIFICATION_KEY, SMART_NOTIFICATION_STATE);
    }
    if(!prefs.containsKey(ASK_LOCATION_PERMISSION_KEY)) {
      prefs.setBool(ASK_LOCATION_PERMISSION_KEY, ASK_LOCATION_PERMISSION);
    }
    if(!prefs.containsKey(NOTIFICATION_ID_KEY)) {
      prefs.setInt(NOTIFICATION_ID_KEY, NOTIFICATION_ID_START);
    }
    if(!prefs.containsKey(LAST_RECOMMENDATION_DATE_KEY)) {
      prefs.setString(LAST_RECOMMENDATION_DATE_KEY,
          formatTimeStamp(DateTime(2020)));
    }
  }

  static void clearNotificationsPrefs() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList(SMART_NOTIFICATION_LIST, null);
    _prefs.setStringList(DEFAULT_NOTIFICATION_LIST, null);
  }

  static void clearAllPreferences() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs = await SharedPreferences.getInstance();
    _prefs.remove(DEFAULT_NOTIFICATION_KEY);
    _prefs.remove(SMART_NOTIFICATION_KEY);
    _prefs.remove(USER_SESSION_KEY);
    _prefs.remove(ASK_LOCATION_PERMISSION_KEY);
    _prefs.remove(SMART_NOTIFICATION_LIST);
    _prefs.remove(DEFAULT_NOTIFICATION_LIST);
    _prefs.remove(NOTIFICATION_ID_KEY);
    _prefs.remove(LAST_RECOMMENDATION_DATE_KEY);
  }

  ///
  /// Helped method to convert the number [n] to its ordinal form.
  /// As in:
  ///
  ///     ordinalNumber(1) = 1st
  ///     ordinalNumber(2) = 2nd
  ///     ordinalNumber(3) = 3rd
  ///     ordinalNumber(4) = 4th
  ///     ordinalNumber(5) = 5th
  ///
  static Floor ordinalNumber(int n){
    String suffix = ['th', 'st', 'nd', 'rd', 'th'][min(n % 10, 4)];
    if (11 <= (n % 100) && (n % 100) <= 13)
      suffix = 'th';
    return new Floor(n.toString() + suffix, n);
  }

  static String buildGoogleMapsLink(Coordinate coord){
    String url = "http://maps.google.com/maps?daddr="
        + "${coord.lat},${coord.long}&z=14" ;
    return url;
  }

  static buildGoogleMapsLink2(Coordinate c1, Coordinate c2){
    String url = "https://www.google.com/maps/dir/${c1.lat},${c1.long}/${c2.lat},"
        "${c2.long}" ;
    return url;
  }

  static String formatTimeStamp(DateTime dateTime){
    return  DateFormat("yyyy-MM-dd hh:mm:ss").format(dateTime);
  }

  static List<int> getRandomNumberList(int length, int min, int max){
    List<int> randomList = List();
    Random rand = Random();
    int num = rand.nextInt(max - min) + min;
    while(randomList.length < length){
      if(!randomList.contains(num)){
        randomList.add(num);
      }
      num = rand.nextInt(max - min) + min;
    }
    return randomList;
  }

}