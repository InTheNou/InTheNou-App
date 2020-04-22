import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_manager.dart';
import 'package:InTheNou/home_page.dart';
import 'package:InTheNou/views/Account/account_creation_view.dart';
import 'package:InTheNou/views/Account/login_view.dart';
import 'package:InTheNou/views/EventFeed/event_creation_view.dart';
import 'package:InTheNou/views/EventFeed/event_detail_view.dart';
import 'package:InTheNou/views/InformoationBase/building_view.dart';
import 'package:InTheNou/views/InformoationBase/floor_view.dart';
import 'package:InTheNou/views/InformoationBase/infobase_search_view.dart';
import 'package:InTheNou/views/InformoationBase/room_view.dart';
import 'package:InTheNou/views/InformoationBase/service_view.dart';
import 'package:InTheNou/views/Profile/created_events_view.dart';
import 'package:InTheNou/views/Profile/followed_events_view.dart';
import 'package:InTheNou/views/Profile/history_events_view.dart';
import 'package:InTheNou/views/Profile/my_tags_view.dart';
import 'package:InTheNou/views/Profile/settings_view.dart';
import "package:flutter/material.dart";

class RouteGenerator{

  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;
    switch (settings.name){
      case "/home":
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: HomePage())
        );
      case "/login":
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: LoginView())
        );
      case "/accountcreation":
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: AccountCreationView())
        );
      case "/eventdetail":
        if (args is int) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                  child: EventDetailView(args)),
          );
        }
        return _errorRoute();
      case '/create_event':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: EventCreationView())
        );
      case '/infobase/search':
        if (args is InfoBaseType) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: InfoBaseSearchView(args)),
          );
        }
        return _errorRoute();
      case '/infobase/building':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: BuildingView())
        );
      case '/infobase/floor':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: FloorView())
        );
      case '/infobase/room':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: RoomView())
        );
      case '/infobase/service':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: ServiceView())
        );
      case '/profile/settings':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: SettingsView())
        );
      case '/profile/followed_events':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: FollowedEventsView())
        );
      case '/profile/event_history':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: HistoryEventsView())
        );
      case '/profile/my_tags':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: MyTagsView())
        );
      case '/profile/created_events':
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => DialogManager(
                child: CreatedEventsView())
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Oops something happened trying to get you to your '
              'destination.'),
        ),
      );
    });
  }
}