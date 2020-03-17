import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/room.dart';

class EventsRepo {

  EventsRepo();

  List<Event> getGenEvents(int userUID, DateTime currentTime, int skipEvents,
      int numEvents){
    return dummyEvents;
  }

  List<Event> getPerEvents(int userUID, DateTime currentTime, int skipEvents,
      int numEvents){
    return dummyEvents;
  }

  List<Event> searchGenEvents(int userUID, String keyword,
      DateTime currentTime, int skipEvents, int numEvents){
    genSearchKeyword = keyword;
    runLocalSearch();
    return genSearch;
  }

  List<Event> searchPerEvents(int userUID, String keyword,
      DateTime currentTime, int skipEvents, int numEvents){
    perSearchKeyword = keyword;
    runLocalSearch();
    return perSearch;
  }

  Event getEvent(int userUID, int eventUID){
    return null;
  }

  void requestFollowEvent(int userUID, int eventUID){
    int index = dummyEvents.indexWhere((event) => event.UID == eventUID);
    dummyEvents[index] = Event.copy(dummyEvents[index], true);
    runLocalSearch();
  }

  void requestUnFollowEvent(int userUID, int eventUID){
    int index = dummyEvents.indexWhere((event) => event.UID == eventUID);
    dummyEvents[index] = Event.copy(dummyEvents[index], false);
    runLocalSearch();
  }

  void requestDismissEvent(int userUID, int eventUID){
    int index = dummyEvents.indexWhere((event) => event.UID == eventUID);
    dummyEvents.removeAt(index);
    runLocalSearch();
  }

  void createEvent(int userUID, Event event){
    return null;
  }

  //---------------------- DEBUGGING STUFF ----------------------
  String perSearchKeyword = "";
  String genSearchKeyword = "";

  List<Event> dummyEvents = List<Event>.generate(
      20,
          (i) =>  Event.result(i, "Event $i With a BIg Name that take us a "
              "lot of sapce", "This is a very long "
              "description fo the event currantly displayed. This is to test "
              "out how good it looks when it cuts off.",
          DateTime.now().add(new Duration(days: i, hours: i+2)),
          DateTime.now().add(new Duration(days: i, hours: i+5)),
          new Room(0, "S-200", "Stefani", 2, "Stefani is Cool", 20,
              "Alguien.importante@upr.edu", new Coordinate(50.0, 30.0)
          ), (i%2 == 0)
      )
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
}

