import 'dart:math';

import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/repos/events_repo.dart';

import 'assets/utils.dart';
import 'models/coordinate.dart';
import 'models/room.dart';
import 'models/website.dart';

class TestHandler {

  static EventsRepo _eventsRepo = EventsRepo();

  static Future<String> dataHandler(String msg) async {
    switch (msg) {
      case "enterEvents":
        _addEvents();
        break;
      default:
        break;
    }
  }

  static void _addEvents(){
    _eventsRepo.dummyEvents = List<Event>.generate(
        5,
            (i) {
          List<int> randList = Utils.getRandomNumberList(10, 0,
              EventsRepo.eventTags.length);
          return Event(i, "Test $i", "This is a very long "
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
                      (i) => EventsRepo.eventTags[randList[i]]
              ),
              false, null
          );
        }
    );
  }

}