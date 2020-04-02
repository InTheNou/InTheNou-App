import 'dart:math';

import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';

class EventsRepo {

  static final EventsRepo _instance = EventsRepo._internal();
  Random rand = Random();

  factory EventsRepo() {
    return _instance;
  }

  EventsRepo._internal();

  /// Calls teh back-end to get the Events for the General Feed
  ///
  /// The method returns all active and non-dismissed Events in the system. The
  /// parameter [skipEvents] can be supplied to let the back-end know the
  /// first event that needs to be returned, this along with [numEvents]
  /// permits performing pagination and only showing a few Events at a time.
  /// To get all the Events at once just supply a very bit number to [numEvents]
  Future<List<Event>> getGenEvents (int skipEvents, int numEvents) async{
    return Future.delayed(Duration(seconds: 2)).then((onValue) {
//      if(rand.nextBool()){
//        return Future.error("Error happened!");
//      }
      return new List.from(dummyEvents);
    });
  }

  /// Calls teh back-end to get the Events for the Personal Feed.
  ///
  /// The method returns all active Recommended and non-dismissed [Event]s in
  /// the system. The parameter [skipEvents] can be supplied to let the
  /// back-end know the first event that needs to be returned, this along
  /// with [numEvents] permits performing pagination and only showing a few
  /// Events at a time.
  /// To get all the Events at once just supply a very bit number to
  /// [numEvents].
  Future<List<Event>> getPerEvents(int skipEvents, int numEvents) async{
    return Future.delayed(Duration(seconds: 2)).then((onValue) {
//      if(rand.nextBool()){
//        return Future.error("Error happened!");
//      }
      return new List.from(dummyEvents.where((event) =>
        event.recommended != null && event.recommended));
    });
  }

  /// Contacts the back-end to get [Event]s created after [lastDate].
  ///
  /// The parameter [lastDate] is a DateTime object in String form, with the
  /// format yyyy-MM-dd hh:mm:ss.
  /// This method is used in the Recommendation Feature.
  Future<List<Event>> getNewEvents(String lastDate) async{
    DateTime date = DateTime.parse(lastDate);
    return new List.from(dummyEvents.where((event) =>
        event.startDateTime.isAfter(date)));
  }

  /// Calls the back-end with a search query for the General Feed
  ///
  /// The method returns all active and non-dismissed Events in the system
  /// that match the [keyword] in their [Event._title] or
  /// [Event._description]. The parameter [skipEvents] can be supplied to let the
  /// back-end know the first event that needs to be returned, this along
  /// with [numEvents] permits performing pagination and only showing a few
  /// Events at a time.
  /// To get all the Events at once just supply a very bit number to [numEvents]
  Future<List<Event>> searchGenEvents(String keyword, int skipEvents,
      int numEvents) async{
    return Future.delayed(Duration(seconds: 2)).then((onValue) {
      genSearchKeyword = keyword;
      runLocalSearch();
      return new List.from(genSearch);
    });
  }

  /// Calls the back-end with a search query for the Personal Feed
  ///
  /// The method returns all Recommended and non-dismissed Events in the
  /// system that match the [keyword] in their [Event._title] or
  /// [Event._description]. The parameter [skipEvents] can be supplied to let
  /// the back-end know the first event that needs to be returned, this along
  /// with [numEvents] permits performing pagination and only showing a few
  /// Events at a time.
  /// To get all the Events at once just supply a very bit number to [numEvents]
  Future<List<Event>> searchPerEvents(String keyword, int skipEvents,
      int numEvents) async{
    return Future.delayed(Duration(seconds: 2)).then((onValue) {
      perSearchKeyword = keyword;
      runLocalSearch();
      return new List.from(perSearch);
    });
  }

  /// Calls the back-end to get all the information on a specific [Event].
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// will return detailed information about the [Event] that matches the UID.
  Future<Event> getEvent(int eventUID) async{
    return dummyEvents.firstWhere((element) =>
      element.UID == eventUID);
  }

  /// Requests for an [Event] to be marked as Followed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being Followed by this user by setting [Event.followed]
  Future<bool> requestFollowEvent(int eventUID) async{
    return Future.delayed(Duration(seconds: 2)).then((onValue) {
//      if(rand.nextBool()){
//        return Future.error("Internal Error Following Event please try again"
//            " later.");
//      }
      int index = dummyEvents.indexWhere((event) => event.UID == eventUID);
      dummyEvents[index].followed = true;
      return true;
    });
  }

  /// Requests for an [Event] to be marked as UnFollowed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being UnFollowed by this user by setting [Event.followed]
  Future<bool> requestUnFollowEvent(int eventUID) async{
    return Future.delayed(Duration(seconds: 2)).then((onValue) {
//      if(rand.nextBool()){
//        return Future.error("Internal Error UnFollowing Event please try again"
//            " later.");
//      }
      int index = dummyEvents.indexWhere((event) => event.UID == eventUID);
      dummyEvents[index].followed = false;
      return true;
    });
  }

  /// Requests for an [Event] to be marked as Dismissed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being Dismissed by this user. Events marked with being
  /// Dismissed will not be returned by other queries.
  Future<bool> requestDismissEvent(int eventUID) async{
    return Future.delayed(Duration(seconds: 2)).then((onValue) {
//      if(rand.nextBool()){
//        return Future.error("Error Dismissing Event please try again later.");
//      }
      int index = dummyEvents.indexWhere((event) => event.UID == eventUID);
      dummyEvents.removeAt(index);
      return true;
    });
  }

  /// Requests for an [Event] to be marked as Recommended in the back-end.
  ///
  /// Given a list of Events through the [events] parameter, the back-end
  /// marks them as being Recommended to this user, setting
  /// [Event.recommended]. Events marked as such will show up in the Personal
  /// Feed.
  Future<bool> requestRecommendation(List<Event> events) async{
    int index;
    events.forEach((event) {
      index = dummyEvents.indexOf(event);
      dummyEvents[index] = event;
    });
    return true;
  }

  /// Requests for an [Event] to be created in the system.
  ///
  /// Given a new Event through the [event] parameter, the back-end
  /// creates an Event in the system with this current user as the
  /// [Event._creator].
  /// An Event created this way will show up in the General Feed, and the
  /// Personal Feed if recommended to a user.
  Future<bool> createEvent(Event event) async{
    dummyEvents.add(event);
    runLocalSearch();
    return true;
  }

  //---------------------- DEBUGGING STUFF ----------------------
  String perSearchKeyword = "";
  String genSearchKeyword = "";

  List<Event> dummyEvents = List<Event>.generate(
      10,
          (i) {
            List<int> randList = Utils.getRandomNumberList(10, 0,
                eventTags.length);
        return Event(i, "Event $i With a Big Name that take us a "
          "lot of space", "This is a very long "
          "description fo the event currantly displayed. This is to test "
          "out how good it looks when it cuts off.", "alguien.importante@upr"
            ".edu",
          "https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg",
          DateTime.now().add(new Duration(minutes: i*2+5)),
          DateTime.now().add(new Duration(minutes: i*20)),
          DateTime.now(),
          new Room(0, "S-200", "Stefani", 2, "Stefani is Cool", 20,
            "Alguien.importante@upr.edu", new Coordinate(18.209641, -67.139923)
          ),
          new List.generate(3, (i) => Website(
            "https://portal.upr.edu/rum/portal.php?a=rea_login",
            "link $i")
          ),
            new List.generate(
            Random().nextInt(7) + 3,
            (i) => eventTags[randList[i]]
            ),
          false, null
          );
        }
  );

  List<Event> genSearch = new List();
  List<Event> perSearch = new List();

  void clearPerSearch() => perSearchKeyword = "";
  void clearGenSearch() => genSearchKeyword = "";
  void runLocalSearch(){
    if (perSearchKeyword.isNotEmpty) {
      perSearch.clear();
      dummyEvents.forEach((element) {
        if (element.title.contains(perSearchKeyword)){
          perSearch.add(element);
        } else if (element.description.contains(perSearchKeyword)){
          perSearch.add(element);
        }
      });
    }
    if(genSearchKeyword.isNotEmpty) {
      genSearch.clear();
      dummyEvents.forEach((element) {
        if (element.title.contains(genSearchKeyword)){
          genSearch.add(element);
        } else if (element.description.contains(genSearchKeyword)){
          genSearch.add(element);
        }
      });
    }
  }

  void deleteEvent(Event event){
    dummyEvents.remove(event);
  }

  static List<Tag> eventTags = [Tag("ADMI",0), Tag("ADOF",0), Tag("AGRO",0), Tag
    ("ALEM",0), Tag("ANTR",0), Tag("ARTE",0), Tag("ASTR",0), Tag("BIND",0),
    Tag("BIOL",0), Tag("BOTA",0), Tag("CFIT",0), Tag("CHIN",0), Tag("CIAN",0)
    , Tag("CIBI",0), Tag("CIFI",0), Tag("CIIC",0), Tag("CIMA",0)];
}

