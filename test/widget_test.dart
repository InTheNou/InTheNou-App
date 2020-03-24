// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:InTheNou/home_page.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/room.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:InTheNou/main.dart';

void main() {
  testWidgets('Event Feed Results', (WidgetTester tester) async {
    // Build our app and trigger a frame.
//    await tester.pumpWidget(InTheNouApp());
//
//
//    while(find.text('PersonalFeed', skipOffstage: true) == null){
//      await tester.pump();
//    }
//
//    expect(find.byElementType(GoogleSignInButton), findsOneWidget);
//
//
//    Event baseEvent = Event(-1, "Event", "Description", "Fernando",
//        "https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg",
//        DateTime(2020), DateTime(2020), DateTime.now(),
//        Room(1, "S-123", "Stefani",1, "Stefani", 30,
//            "Alguien.importante@upr.edu", Coordinate(18.209641, -67.139923))
//        , [Website("upr.edu", "UPR")], [Tag("Tag1", 10)], true);
//
//    EventsRepo eventRepo = new EventsRepo();
//    eventRepo.dummyEvents = List<Event>.generate(
//        5,
//            (i) =>  Event(i, baseEvent.title+"$i", baseEvent.description,
//                baseEvent.creator, baseEvent.image,
//                baseEvent.startDateTime, baseEvent.endDateTime, baseEvent.timestamp,
//                baseEvent.room, baseEvent.websites, baseEvent.tags, baseEvent.followed
//        )
//    );
//
//   await tester.tap(find.byIcon(Icons.search));
//    await tester.pumpAndSettle();
//
//    expect(find.text('Event0'), findsOneWidget);
//    expect(find.text('Event1'), findsOneWidget);
//    expect(find.text('Event2'), findsOneWidget);
//    expect(find.text('Event3'), findsOneWidget);
//    expect(find.text('Event4'), findsOneWidget);
//    expect(find.text('Event5'), findsNothing);
//    expect(find.text('Description'), findsNWidgets(5));

  });
}
