import 'dart:io';
import 'dart:math';
import 'dart:convert' as convert;
import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:http/http.dart' as http;

class EventsRepo {

  static final EventsRepo _instance = EventsRepo._internal();
  Random rand = Random();
  var client = http.Client();

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
    return client.get(API_URL+
        "/App/Events/General/uid=4/offset=$skipEvents/limit=$numEvents")
        .then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Event> eventResults = new List();
        List jsonResponse = convert.jsonDecode(response.body)["events"];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            eventResults.add(Event.resultFromJson(element));
          });
        }
        return eventResults;
      } else {
        return Utils.createError("Getting General Events",
            response.statusCode, convert.jsonDecode(response.body)["Error"]);
      }
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
    return client.get(API_URL+
        "/App/Events/Recommended/uid=4/offset=$skipEvents/limit=$numEvents")
        .then((response) {
          if (response.statusCode == HttpStatus.ok) {
            List<Event> eventResults = new List();
            List jsonResponse = convert.jsonDecode(response.body)["events"];
            if(jsonResponse != null){
              jsonResponse.forEach((element) {
                eventResults.add(Event.resultFromJson(element));
              });
            }
            return eventResults;
          } else {
            return Utils.createError("Getting Recommended Events",
                response.statusCode, convert.jsonDecode(response.body)["Error"]);
          }
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
    return client.get(API_URL+
        "/App/Events/General/search=$keyword/offset=$skipEvents/limit=$numEvents"
            "/uid=4").then((response) {
          if (response.statusCode == HttpStatus.ok) {
            List<Event> eventResults = new List();
            List jsonResponse = convert.jsonDecode(response.body)["events"];
            if(jsonResponse != null){
              jsonResponse.forEach((element) {
                eventResults.add(Event.resultFromJson(element));
              });
            }
            return eventResults;
          } else {
            return Utils.createError("Searching General Events",
                response.statusCode, convert.jsonDecode(response.body)["Error"]);
          }
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
    return client.get(API_URL+
        "/App/Events/Recommended/search=$keyword/offset=$skipEvents/limit"
            "=$numEvents/uid=4").then((response) {
          if (response.statusCode == HttpStatus.ok) {
            List<Event> eventResults = new List();
            List jsonResponse = convert.jsonDecode(response.body)["events"];
            if(jsonResponse != null){
              jsonResponse.forEach((element) {
                eventResults.add(Event.resultFromJson(element));
              });
            }
            return eventResults;
          } else {
            return Utils.createError("Searching Recommended Events",
                response.statusCode, convert.jsonDecode(response.body)["Error"]);
          }
        });
  }

  /// Calls the back-end to get all the information on a specific [Event].
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// will return detailed information about the [Event] that matches the UID.
  Future<Event> getEvent(int eventUID) async{
    return client.get(API_URL+ "/App/Events/eid=$eventUID/uid=4").then(
            (response) {
       if (response.statusCode == HttpStatus.ok) {
         return Event.fromJson(convert.jsonDecode(response.body));
       } else {
         return Utils.createError("Getting Event", response.statusCode,
             convert.jsonDecode(response.body)["Error"]);
       }
    });
  }

  /// Requests for an [Event] to be marked as Followed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being Followed by this user by setting [Event.followed]
  Future<bool> requestFollowEvent(int eventUID) async{
    return client.post(API_URL+
        "/App/Events/eid=$eventUID/uid=4/Follow").then((response) {
          if (response.statusCode == HttpStatus.created) {
            return convert.jsonDecode(response.body)["event"]["eid"] == eventUID;
          } else {
            return Utils.createError("Follow", response.statusCode,
                convert.jsonDecode(response.body)["Error"]);
          }
        });
  }

  /// Requests for an [Event] to be marked as UnFollowed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being UnFollowed by this user by setting [Event.followed]
  Future<bool> requestUnFollowEvent(int eventUID) async{
    return client.post(API_URL+
        "/App/Events/eid=$eventUID/uid=4/Unfollow").then((response) {
      if (response.statusCode == HttpStatus.created) {
        return convert.jsonDecode(response.body)["event"]["eid"] == eventUID;
      } else {
        return Utils.createError("Unfollow", response.statusCode,
            convert.jsonDecode(response.body)["Error"]);
      }
    });
  }

  /// Requests for an [Event] to be marked as Dismissed in the back-end.
  ///
  /// Given the [Event._UID] through the [eventUID] parameter, the back-end
  /// marks it as being Dismissed by this user. Events marked with being
  /// Dismissed will not be returned by other queries.
  Future<bool> requestDismissEvent(int eventUID) async{
    return client.post(API_URL+ "/App/Events/eid=$eventUID/uid=4/Dismiss")
        .then((response) {
      if (response.statusCode == HttpStatus.created) {
        return convert.jsonDecode(response.body)["event"]["eid"] == eventUID;
      } else {
        return Utils.createError("Dismiss", response.statusCode,
            convert.jsonDecode(response.body)["Error"]);
      }
    });
  }

  /// Requests for an [Event] to be marked as Recommended in the back-end.
  ///
  /// Given a list of Events through the [events] parameter, the back-end
  /// marks them as being Recommended to this user, setting
  /// [Event.recommended]. Events marked as such will show up in the Personal
  /// Feed.
  Future<List<bool>> requestRecommendation(List<Event> events) async{
    Future<List<bool>> result;
    result = Future.wait<bool>(events.map((event) async{
      return await client.post(API_URL+
          "/App/Events/eid=${event.UID}/uid=4/recommendstatus="
              "${event.recommended}").then((response) {
        if (response.statusCode == HttpStatus.created) {
          if(convert.jsonDecode(response.body)["eid"] == event.UID){
            return true;
          } else {
            return Utils.createError("Reccomendation", null, null);
          }
        } else {
          return Utils.createError("Reccomendation", response.statusCode,
              convert.jsonDecode(response.body)["Error"]);
        }
      });
    }));
    return result;
  }

  /// Requests for an [Event] to be created in the system.
  ///
  /// Given a new Event through the [event] parameter, the back-end
  /// creates an Event in the system with this current user as the
  /// [Event._creator].
  /// An Event created this way will show up in the General Feed, and the
  /// Personal Feed if recommended to a user.
  Future<bool> createEvent(Event event) async{
    return client.post(API_URL+ "/App/Events/Create",
        headers: {"Content-Type": "application/json"},
        body: convert.jsonEncode(event.toJson())).then((response) {
      if (response.statusCode == HttpStatus.created) {
        return convert.jsonDecode(response.body)["eid"] == event.UID;
      } else {
        return Utils.createError("Create Event", response.statusCode,
            convert.jsonDecode(response.body)["Error"]);
      }
    });
  }

  //---------------------- DEBUGGING STUFF ----------------------
  String perSearchKeyword = "";
  String genSearchKeyword = "";

  List<Event> dummyEvents = List<Event>.generate(
      10,
          (i) {
            List<int> randList = Utils.getRandomNumberList(10, 0,
                eventTags.length);
        return Event(i, "Event $i", "This is a very long "
          "description fo the event currantly displayed. This is to test "
          "out how good it looks when it cuts off.", "alguien.importante1@upr"
            ".edu",
          "https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg",
          DateTime.now().add(new Duration(minutes: i*2+5)),
          DateTime.now().add(new Duration(minutes: i*20)),
          DateTime.now(),
          new Room(0, "S-200", "Stefani", 2, "Stefani is Cool", 20,
            "Alguien.importante@upr.edu",
              new Coordinate(18.209641, -67.139923,0)
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

  static List<Tag> eventTags = [Tag(1,"ADMI",0), Tag(2,"ADOF",0),
    Tag(3,"AGRO",0), Tag(4,"ALEM",0), Tag(5,"ANTR",0), Tag(6,"ARTE",0),
    Tag(7,"ASTR",0), Tag(8,"BIND",0), Tag(9,"BIOL",0), Tag(10,"BOTA",0),
    Tag(11,"CFIT",0), Tag(12,"CHIN",0), Tag(13,"CIAN",0), Tag(14,"CIBI",0),
    Tag(15,"CIFI",0), Tag(16,"CIIC",0), Tag(17,"CIMA",0)];
}

