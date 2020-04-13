import 'dart:math';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'assets/utils.dart';
import 'models/coordinate.dart';
import 'models/room.dart';
import 'models/tag.dart';
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
    var dummyEvents = List<Event>.generate(
        5,
            (i) {
          List<int> randList = Utils.getRandomNumberList(10, 0,
              eventTags.length);
          return Event(i, "Test $i", "This is a very long "
              "description fo the event currantly displayed. This is to test "
              "out how good it looks when it cuts off.", "alguien.importante@upr"
              ".edu",
              "https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg",
              DateTime.now().add(new Duration(minutes: i*2+5)),
              DateTime.now().add(new Duration(minutes: i*20)),
              DateTime.now(),
              new Room(0, "S-200", "Stefani", 2, "Stefani is Cool", 20,
                  "Alguien.importante@upr.edu",
                  new Coordinate(18.209641, -67.139923, 0)
              ),
              new List.generate(3, (i) => Website(
                  "https://portal.upr.edu/rum/portal.php?a=rea_login",
                  "link $i")
              ),
              new List.generate(
                  Random().nextInt(7) + 3,
                      (i) => eventTags[randList[i]]
              ),
              false, null, 'active'
          );
        }
    );
  }
  static List<Tag> eventTags = [Tag(1,"ADMI",0), Tag(2,"ADOF",0),
    Tag(3,"AGRO",0), Tag(4,"ALEM",0), Tag(5,"ANTR",0), Tag(6,"ARTE",0),
    Tag(7,"ASTR",0), Tag(8,"BIND",0), Tag(9,"BIOL",0), Tag(10,"BOTA",0),
    Tag(11,"CFIT",0), Tag(12,"CHIN",0), Tag(13,"CIAN",0), Tag(14,"CIBI",0),
    Tag(15,"CIFI",0), Tag(16,"CIIC",0), Tag(17,"CIMA",0)];
}