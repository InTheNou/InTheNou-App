import 'dart:math';

import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';

class EventsRepo {

  static final EventsRepo _instance = EventsRepo._internal();

  factory EventsRepo() {
    return _instance;
  }

  EventsRepo._internal();

  List<Event> getGenEvents(int userUID, DateTime currentTime, int skipEvents,
      int numEvents){
    return new List.from(dummyEvents);
  }

  List<Event> getPerEvents(int userUID, DateTime currentTime, int skipEvents,
      int numEvents){
    return new List.from(dummyEvents.where((event) =>
      event.recommended != null && event.recommended));
  }

  Future<List<Event>> getNewEvents(String lastDate) async{
    DateTime date = DateTime.parse(lastDate);
    return new List.from(dummyEvents.where((event) =>
        event.startDateTime.isAfter(date)));
  }

  List<Event> searchGenEvents(int userUID, String keyword,
      DateTime currentTime, int skipEvents, int numEvents){
    genSearchKeyword = keyword;
    runLocalSearch();
    return new List.from(genSearch);
  }

  List<Event> searchPerEvents(int userUID, String keyword,
      DateTime currentTime, int skipEvents, int numEvents){
    perSearchKeyword = keyword;
    runLocalSearch();
    return new List.from(perSearch);
  }

  Event getEvent(int userUID, int eventUID){
    return dummyEvents.firstWhere((element) =>
      element.UID == eventUID);
  }

  bool requestFollowEvent(int userUID, int eventUID){
    int index = dummyEvents.indexWhere((event) => event.UID == eventUID);
    dummyEvents[index].followed = true;
    return true;
  }

  bool requestUnFollowEvent(int userUID, int eventUID){
    int index = dummyEvents.indexWhere((event) => event.UID == eventUID);
    dummyEvents[index].followed = false;
    return true;
  }

  bool requestDismissEvent(int userUID, int eventUID){
    int index = dummyEvents.indexWhere((event) => event.UID == eventUID);
    dummyEvents.removeAt(index);
    return true;
  }

  bool requestRecommendation(List<Event> events){
    int index;
    events.forEach((event) {
      index = dummyEvents.indexOf(event);
      dummyEvents[index] = event;
    });
    return true;
  }

  bool createEvent(int userUID, Event event){
    dummyEvents.add(event);
    runLocalSearch();
    return true;
  }

  //---------------------- DEBUGGING STUFF ----------------------
  String perSearchKeyword = "";
  String genSearchKeyword = "";

  List<Event> dummyEvents = List<Event>.generate(
      30,
          (i) {
            List<int> randList = Utils.getRandomNumberList(10, 0,
                eventTags.length);
        return Event(i, "Event $i With a Big Name that take us a "
          "lot of space", "This is a very long "
          "description fo the event currantly displayed. This is to test "
          "out how good it looks when it cuts off.", "Alguien Importante",
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

