import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/validators.dart';
import 'package:InTheNou/models/coordinate.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:test/test.dart';

void main(){
  group("InTheNou Tests", (){
    group("Event Creation Validation", (){
      group("Event Title Validation", (){
        test('Title Empty', () {
          expect(Validators.validateTitle(""), "Title must be provided");
        });
        test('Title full of spaces', () {
          expect(Validators.validateTitle("     "), "Title is too short");
        });
        test('Title shorter than 3', () {
          expect(Validators.validateTitle("hi"), "Title is too short");
        });
        test('Title less than 50', () {
          expect(Validators.validateTitle
            ("Lorem ipsum dolor sit amet")
              , null);
        });
        test('Title bigger than 50', () {
          expect(Validators.validateTitle
            ("Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
              "Phasellus et mauris et mi feugiat vestibulum. Nullam odio mauris, "
              "ornare ut viverra sed, aliquet eget neque"), "Title is too long");
        });
      });
      group("Event Description Validation", (){
        test('Description Empty', () {
          expect(Validators.validateDescription(""), "Description must be provided");
        });
        test('Description full of spaces', () {
          expect(Validators.validateDescription("      "), "Description is too short");
        });
        test('Description shorter than 3', () {
          expect(Validators.validateDescription("hi"), "Description is too short");
        });
        test('Description less than 400', () {
          expect(Validators.validateDescription
            ("Lorem ipsum dolor sit amet")
              , null);
        });
        test('Description bigger than 400', () {
          expect(Validators.validateDescription
            ("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam "
              "lectus est, molestie a maximus in, tempor eget elit. Morbi aliquet "
              "aliquam dignissim. Donec finibus vitae lorem nec sagittis. "
              "Curabitur sed orci a felis ornare viverra. Nunc eu sapien mattis, "
              "pretium nisl sit amet, rutrum orci. Aenean in pellentesque nibh, "
              "nec tempor velit. Suspendisse convallis leo nec sodales "
              "condimentum. Proin vitae. "),
              "Description is too long");
        });
      });
      group("Event Image Validation", (){
        test('Image Empty', () {
          expect(Validators.validateImage(""), null);
        });
        test('Image full of spaces', () {
          expect(Validators.validateImage("      "), "Image link is too short");
        });
        test('Image shorter than 3', () {
          expect(Validators.validateImage("hi"), "Image link is too short");
        });
        test('Image invalid URL', () {
          expect(Validators.validateImage("https:/images"),
              "Invalid Image link");
        });
        test('Image less than 400', () {
          expect(Validators.validateImage
            ("https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg")
              , null);
        });
        test('Image bigger than 400', () {
          expect(Validators.validateImage
            ("https://images.pexels.com/photos/256541/pexels-photo-256541"
              "LoremipsumdolorsitametconsecteturdipiscingelitAlihgfdhgquam"
              "lectusestmolestieamaximusintemporegetelitMohgfdhgdfrbialiquet"
              "aliquamdignissiDonecfinibusvitaeloremnecsahgfdhhgfdhgfdgittis"
              "CurabitursedorciafelisornareviverraNunceusapienhgfdhgmattis"
              "pretiumnislsitametrutrumorciAeneaninpelhlenteshgfdhghgquenibh"
              "nectemporelitSuspendisseconvalliseonecsohgfshfhgfdhdales"
              "condimentumProinvitaefdsafdafdsafdsahfshgfdhgfd"),
              "Image link is too long");
        });
      });
      group("Event Dates Validation", (){
        test('Start Date Empty', () {
          expect(Validators.validateDate(null, null ,null), "Insert Date");
        });
        test('End Date Empty', () {
          expect(Validators.validateDate(null, null ,null), "Insert Date");
        });
        test('Duration bigger than 7 days', () {
          expect(Validators.validateDate(DateTime.now(), DateTime.now(),
              DateTime.now().add(Duration(hours: 169))),
              "Event Duration too long");
        });
        test('Duration shorter than 7 days', () {
          expect(Validators.validateDate(DateTime.now(), DateTime.now(),
              DateTime.now().add(Duration(hours: 168))), null);
        });
        test('Duration shorter than 5 minutes', () {
          expect(Validators.validateDate(DateTime.now(), DateTime.now(),
              DateTime.now().add(Duration(minutes: 4))), 'Event Duration too short');
        });
        test('Start Date after End Date', () {
          expect(Validators.validateDate(DateTime.now(),
              DateTime.now().add(Duration(seconds: 1)),
              DateTime.now()), "Event Start After Event End");
        });
      });
      group("Event Website Description Validation", (){
        test('Website Description Empty', () {
          expect(Validators.validateWebsiteDescription(""), null);
        });
        test('Website Description full of spaces', () {
          expect(Validators.validateWebsiteDescription("      "), "Website Description is too short");
        });
        test('Website shorter than 3', () {
          expect(Validators.validateWebsiteDescription("hi"), "Website Description is too short");
        });
        test('Website less than 50', () {
          expect(Validators.validateWebsiteDescription
            ("Lorem ipsum dolor sit amet")
              , null);
        });
        test('Image bigger than 50', () {
          expect(Validators.validateWebsiteDescription
            ("https://images.pexels.com/photos/256541/pexels-photo-256541"
              "LoremipsumdolorsitametconsecteturdipiscingelitAlihgfdhgquam"
              "lectusestmolestieamaximusintemporegetelitMohgfdhgdfrbialiquet"
              "aliquamdignissiDonecfinibusvitaeloremnecsahgfdhhgfdhgfdgittis"
              "CurabitursedorciafelisornareviverraNunceusapienhgfdhgmattis"
              "pretiumnislsitametrutrumorciAeneaninpelhlenteshgfdhghgquenibh"
              "nectemporelitSuspendisseconvalliseonecsohgfshfhgfdhdales"
              "condimentumProinvitaefdsafdafdsafdsahfshgfdhgfd"),
              "Website Description is too long");
        });
      });
      group("Event Website Link Validation", (){
        test('Website Link Empty', () {
          expect(Validators.validateWebsiteLink(""), "URL is required");
        });
        test('Website Link full of spaces', () {
          expect(Validators.validateWebsiteLink("      "), "URL is too short");
        });
        test('Website Link shorter than 3', () {
          expect(Validators.validateWebsiteLink("hi"), "URL is too short");
        });
        test('Website Link less than 400', () {
          expect(Validators.validateWebsiteLink
            ("https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg")
              , null);
        });
        test('Website Link invalid URL', () {
          expect(Validators.validateWebsiteLink
            ("https:/images"), "Invalid URL");
        });
        test('Website Link bigger than 400', () {
          expect(Validators.validateWebsiteLink
            ("https://images.pexels.com/photos/256541/pexels-photo-256541"
              "LoremipsumdolorsitametconsecteturdipiscingelitAlihgfdhgquam"
              "lectusestmolestieamaximusintemporegetelitMohgfdhgdfrbialiquet"
              "aliquamdignissiDonecfinibusvitaeloremnecsahgfdhhgfdhgfdgittis"
              "CurabitursedorciafelisornareviverraNunceusapienhgfdhgmattis"
              "pretiumnislsitametrutrumorciAeneaninpelhlenteshgfdhghgquenibh"
              "nectemporelitSuspendisseconvalliseonecsohgfshfhgfdhdales"
              "condimentumProinvitaefdsafdafdsafdsahfshgfdhgfd"),
              "URL is too long");
        });
      });
      group("Event Website quantity Validation", (){
        test('Event Websites Empty', () {
          expect(Validators.validateWebsiteQuantity(List<Website>()), true);
        });
        test('Event Websites > 10', () {
          expect(Validators.validateWebsiteQuantity(List<Website>(11)), false);
        });
        test('Event Websites = 5', () {
          expect(Validators.validateWebsiteQuantity(List<Website>(5)), true);
        });
      });
      group("Event Tags Validation", (){
        test('Event Tags Empty', () {
          expect(Validators.validateSelectedTags(List<Tag>()), false);
        });
        test('Event Tags < 3', () {
          expect(Validators.validateSelectedTags(List<Tag>(2)), false);
        });
        test('Event Tags > 10', () {
          expect(Validators.validateSelectedTags(List<Tag>(11)), false);
        });
        test('Event Tags = 5', () {
          expect(Validators.validateSelectedTags(List<Tag>(5)), true);
        });
      });
    });
    group("GPS Calculations", (){
      test('GPS time to event > 24 hours', () {
        DateTime timestamp = new DateTime.now();
        DateTime startDateTime = new DateTime.now().add(Duration(hours: 25));
        Duration timeToEvent;
        Coordinate userCoords = Coordinate(18.211183333333334, -67.14078833333333);
        Coordinate eventCoords = Coordinate(18.209641, -67.139923);

        timeToEvent = startDateTime.difference(timestamp);
        bool isEventInTheNextDay = Utils.isEventInTheNextDay(startDateTime, timestamp);
        expect(isEventInTheNextDay, false);
        if (isEventInTheNextDay) {
          double timeToWalk = Utils.GPSTimeToWalkCalculation(timeToEvent,
              userCoords, eventCoords);
          expect(Utils.isScheduleSmartNecessary(timeToEvent, timeToWalk), false);
        }
      });
      test('GPS event start time in the past', () {
        DateTime timestamp = new DateTime.now();
        DateTime startDateTime = new DateTime.now().subtract(Duration(minutes: 1));
        Duration timeToEvent;
        Coordinate userCoords = Coordinate(18.211183333333334, -67.14078833333333);
        Coordinate eventCoords = Coordinate(18.209641, -67.139923);

        timeToEvent = startDateTime.difference(timestamp);
        bool isEventInTheNextDay = Utils.isEventInTheNextDay(startDateTime, timestamp);
        expect(isEventInTheNextDay, false);
        if (isEventInTheNextDay) {
          double timeToWalk = Utils.GPSTimeToWalkCalculation(timeToEvent,
              userCoords, eventCoords);
          expect(Utils.isScheduleSmartNecessary(timeToEvent, timeToWalk), false);
        }
      });
      test('GPS time to event < 24 hours, timeToEvent-15min > timeToWalk', () {
        DateTime timestamp = new DateTime.now();
        DateTime startDateTime = new DateTime.now().add(Duration(minutes: 40));
        Duration timeToEvent;
        Coordinate userCoords = Coordinate(18.211183333333334, -67.14078833333333);
        Coordinate eventCoords = Coordinate(18.209641, -67.139923);

        timeToEvent = startDateTime.difference(timestamp);
        bool isEventInTheNextDay = Utils.isEventInTheNextDay(startDateTime, timestamp);
        expect(isEventInTheNextDay, true);
        if (isEventInTheNextDay) {
          double timeToWalk = Utils.GPSTimeToWalkCalculation(timeToEvent,
              userCoords, eventCoords);
          expect(Utils.isScheduleSmartNecessary(timeToEvent, timeToWalk), false);
        }
      });
      test('GPS timeToEvent-15min < timeToWalk test1', () {
        DateTime timestamp = new DateTime.now();
        DateTime startDateTime = new DateTime.now().add(Duration(minutes: 17));
        Duration timeToEvent;
        Coordinate userCoords = Coordinate(18.211183333333334, -67.14078833333333);
        Coordinate eventCoords = Coordinate(18.209641, -67.139923);

        timeToEvent = startDateTime.difference(timestamp);
        bool isEventInTheNextDay = Utils.isEventInTheNextDay(startDateTime, timestamp);
        expect(isEventInTheNextDay, true);
        if (isEventInTheNextDay) {
          double timeToWalk = Utils.GPSTimeToWalkCalculation(timeToEvent,
              userCoords, eventCoords);
          expect(Utils.isScheduleSmartNecessary(timeToEvent, timeToWalk), true);
        }
      });
      test('GPS timeToEvent-15min < timeToWalk test2', () {
        DateTime timestamp = new DateTime.now();
        DateTime startDateTime = new DateTime.now().add(Duration(minutes: 30));
        Duration timeToEvent;
        Coordinate userCoords = Coordinate(18.220244, -67.152635);
        Coordinate eventCoords = Coordinate(18.209641, -67.139923);

        timeToEvent = startDateTime.difference(timestamp);
        bool isEventInTheNextDay = Utils.isEventInTheNextDay(startDateTime, timestamp);
        expect(isEventInTheNextDay, true);
        if (isEventInTheNextDay) {
          double timeToWalk = Utils.GPSTimeToWalkCalculation(timeToEvent,
              userCoords, eventCoords);
          expect(Utils.isScheduleSmartNecessary(timeToEvent, timeToWalk), true);
        }
      });
    });

    group("Default Notification not in the past",(){
      test('Event Start in the Past', () {
        DateTime timestamp = new DateTime.now();
        DateTime startDateTime = new DateTime.now()
            .subtract(Duration(minutes: 1));
        expect(Utils.isScheduleDefaultNecessary(startDateTime, timestamp), false);
      });
      test('Event Start in the future', () {
        DateTime timestamp = new DateTime.now();
        DateTime startDateTime = new DateTime.now()
            .add(Duration(minutes: 1));
        expect(Utils.isScheduleDefaultNecessary(startDateTime, timestamp), true);
      });
    });
  });

}