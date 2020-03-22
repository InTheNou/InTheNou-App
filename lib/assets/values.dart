import 'dart:math';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/floor.dart';
import 'package:shared_preferences/shared_preferences.dart';

//------------------- Enums and constants --------------------

enum FeedType{
  GeneralFeed,
  PersonalFeed
}

enum InfoBaseSearchType{
  Building,
  Room,
  Service
}

enum PhoneType{
  C,
  E,
  F,
  L,
  M
}

enum UserRole{
  Student,
  TeachingPersonnel,
  NonTeachingPersonnel
}

enum UserPrivilege{
  User,
  EventCreator,
  Moderator,
  Administrator
}

//Constants
const EVENTS_TO_FETCH = 20;
const DEFAULT_NOTIFICATION_TIME = 30;
const SMART_NOTIFICATION_STATE = true;
//Shared Preferences Keys
const DEFAULT_NOTIFICATION_KEY = "defaultNotificationTime";
const SMART_NOTIFICATION_KEY = "smartNotificationEnabled";
const USER_SESSION_KEY = "userSession";


//------------------- Helper Methods --------------------

String feedTypeString(FeedType feedType) =>
    feedType == FeedType.PersonalFeed ? "PersonalFeed" : "GeneralFeed";

String infoBaseSearchString(InfoBaseSearchType type) =>
    type == InfoBaseSearchType.Building ? "Buildings Search" :
    type == InfoBaseSearchType.Room ? "Rooms Search" : "Services Search";

String telephoneTypeString(PhoneType telephoneType) =>
  telephoneType == PhoneType.C ? "C" :
  telephoneType == PhoneType.E ? "E" :
  telephoneType == PhoneType.F ? "F" :
  telephoneType == PhoneType.L ? "L" : "M";

String userPrivilegeString(UserPrivilege type) =>
    type == UserPrivilege.User ? "User" :
    type == UserPrivilege.EventCreator ? "Event Creator" :
    type == UserPrivilege.Moderator ? "Moderator" : "Administrator";

String userRoleString(UserRole type) =>
    type == UserRole.Student ? "Student" :
    type == UserRole.TeachingPersonnel ? "Teaching Personnel" :
    "Non Teaching Personnel";

///  Check if shared preferences has been setup, if not then set the default
/// values
Future<void> checkSharedPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(!prefs.containsKey(DEFAULT_NOTIFICATION_KEY)){
    print("writing");
    prefs.setInt(DEFAULT_NOTIFICATION_KEY, DEFAULT_NOTIFICATION_TIME);
  }
  if(!prefs.containsKey(SMART_NOTIFICATION_KEY)) {
    print("writing");
    prefs.setBool(SMART_NOTIFICATION_KEY, SMART_NOTIFICATION_STATE);
  }

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
Floor ordinalNumber(int n){
  String suffix = ['th', 'st', 'nd', 'rd', 'th'][min(n % 10, 4)];
  if (11 <= (n % 100) && (n % 100) <= 13)
    suffix = 'th';
  return new Floor(n.toString() + suffix, n);
}

String buildGoogleMapsLink(Coordinate coord){
  String url = "http://maps.google.com/maps?daddr="
      + "${coord.lat},${coord.long}&z=14" ;
  return url;
}

