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

  ///
  /// Calculation of the Great Circle Distance between two GPS coordinates.
  /// This method uses the Haversine formula and takes into account the
  /// curvature of the earth into the measurement, this makes it very
  /// accurate in small distances, as opposed to using plain trigonometry or
  /// other methods that take the Earth as a flat plane.
  /// For a great explanation please visit this site:
  /// http://mathforum.org/library/drmath/view/51879.html
  ///
  /// The result is multiplied by 1.3 to account for the Euclidian distance
  /// calculation being different than if we take into account the walking
  /// maths.
  /// https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3835347/
  static double greatCircleDistanceCalc(Coordinate userCoords,
      Coordinate eventCoords){
    int earthRad = 3959;
    double uLat = toRadians(userCoords.lat);
    double eLat = toRadians(eventCoords.lat);
    double deltaLat = toRadians(eventCoords.lat - userCoords.lat);
    double deltaLong = toRadians(eventCoords.long - userCoords.long);

    double a = (sin(deltaLat/2) * sin(deltaLat/2)) +
        sin(deltaLong/2) * sin(deltaLong/2) * cos(uLat) * cos(eLat);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double distance = earthRad * c;
    return distance*1.3;
  }

  ///
  /// Here we divide the distance by the average walking speed of 3mph. Then
  /// we multiply by 60 minutes to get the time it would take to walk to the
  /// event in minutes.
  ///
  ///  [distance] (mi)                      60 min
  /// ---------------------------------- * ------- = timeToWalk (min)
  /// [AVERAGE_WALKING_SPEED] (mph)          1 hr
  ///
  static double timeToTravel(double distance){
    return (distance/AVERAGE_WALKING_SPEED)*60;
  }

  static double distanceToTravel(double time){
    return (time/60)*AVERAGE_WALKING_SPEED;
  }

  static double toRadians(double val){
    return val*pi/180;
  }

  static String toSmartTime(double min){
    NumberFormat nf = NumberFormat("##", "en_US");
    Duration timeToWalk = Duration(minutes: min.floor(),
        seconds: ((min - min.floor()) * 60).ceil());
    if(timeToWalk.inMinutes <1){
      return timeToWalk.inSeconds.toString() + " seconds ";
    } else if(timeToWalk.inMinutes < 60){
      return timeToWalk.inMinutes.toString() + " minutes and "+
          nf.format(timeToWalk.inSeconds.remainder(60))+ " seconds ";
    } else if(timeToWalk.inHours < 2){
      return "1 hour and"+
          nf.format(timeToWalk.inMinutes.remainder(60))+ " minutes and "+
          nf.format(timeToWalk.inSeconds.remainder(60))+ " seconds";
    } else if(timeToWalk.inHours < 24){
      return timeToWalk.inHours.toString() + " hours,"+
          nf.format(timeToWalk.inMinutes.remainder(60))+ " minutes and "+
          nf.format(timeToWalk.inSeconds.remainder(60))+ " seconds";
    } else if(timeToWalk.inDays < 7){
      return timeToWalk.inDays.toString() + " days,"+
          nf.format(timeToWalk.inHours.remainder(24))+ " hours, "+
          nf.format(timeToWalk.inMinutes.remainder(60))+ " minutes and "+
          nf.format(timeToWalk.inSeconds.remainder(60))+ " seconds";
    } else if(timeToWalk.inDays < 30){
      return nf.format(timeToWalk.inDays/7) + " weeks,"+
          nf.format(timeToWalk.inDays.remainder(7))+ " days,"+
          nf.format(timeToWalk.inHours.remainder(24))+ " hours,"+
          nf.format(timeToWalk.inMinutes.remainder(60))+ " minutes and "+
          nf.format(timeToWalk.inSeconds.remainder(60))+ " seconds";
    } else if((timeToWalk.inDays/7).remainder(4) < 1){
      return nf.format(timeToWalk.inDays/30) + " months, "+
          nf.format(timeToWalk.inDays.remainder(7))+ " days, "+
          nf.format(timeToWalk.inHours.remainder(24))+ " hours, "+
          nf.format(timeToWalk.inMinutes.remainder(60))+ " minutes and "+
          nf.format(timeToWalk.inSeconds.remainder(60))+ " seconds";
    } else {
      return nf.format(timeToWalk.inDays/30) + " months, "+
          nf.format((timeToWalk.inDays/7).remainder(4))+ " weeks, "+
          nf.format(timeToWalk.inDays.remainder(7))+ " days, "+
          nf.format(timeToWalk.inHours.remainder(24))+ " hours, "+
          nf.format(timeToWalk.inMinutes.remainder(60))+ " minutes and "+
          nf.format(timeToWalk.inSeconds.remainder(60))+ " seconds";
    }
  }

  static bool isEventInTheNextDay(DateTime eventStartDate, DateTime timestamp){
    Duration timeToEvent = eventStartDate.difference(timestamp);
    return timeToEvent.inHours < 24 && !timeToEvent.isNegative;
  }

  static bool isScheduleSmartNecessary(Duration timeToEvent, double timeToWalk){
    return timeToEvent.inMinutes - 15 < timeToWalk;
  }

  static bool isScheduleDefaultNecessary(DateTime eventStartDate, DateTime timestamp){
    return !eventStartDate.difference(timestamp).isNegative;
  }


  static double GPSTimeToWalkCalculation(Duration timeToEvent, Coordinate
  userCoords, Coordinate eventCoords){
      double distance = greatCircleDistanceCalc(userCoords, eventCoords);
      double timeToWalk = timeToTravel(distance);
        print("user: $userCoords");
        print("event: $eventCoords}");
        print("[SmartNotification] Starts in: ${timeToEvent.toString()}");
        print("[SmartNotification] We calculated: $distance distance "
            "$timeToWalk minutes of walking");
        print(buildGoogleMapsLink2(userCoords, eventCoords));
    return timeToWalk;
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