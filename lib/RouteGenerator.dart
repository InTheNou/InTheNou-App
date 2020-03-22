import 'package:InTheNou/assets/values.dart';
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
import 'package:InTheNou/views/Profile/settings_view.dart';
import "package:flutter/material.dart";

class RouteGenerator{

  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;
    switch (settings.name){
      case "/home":
        return MaterialPageRoute(builder: (_) => HomePage());
      case "/login":
        return MaterialPageRoute(builder: (_) => LoginView());
      case "/accountcreation":
        return MaterialPageRoute(builder: (_) => AccountCreationView());
      case "/eventdetail":
        if (args is FeedType) {
          return MaterialPageRoute(
            builder: (_) =>
                EventDetailView(args),
          );
        }
        return _errorRoute();
      case '/create_event':
        return MaterialPageRoute(builder: (_) => EventCreationView());
      case '/infobase/search':
        if (args is InfoBaseSearchType) {
          return MaterialPageRoute(
            builder: (_) =>
                InfoBaseSearchView(args),
          );
        }
        return _errorRoute();
      case '/infobase/building':
        return MaterialPageRoute(builder: (_) => BuildingView());
      case '/infobase/floor':
        return MaterialPageRoute(builder: (_) => FloorView());
      case '/infobase/room':
        return MaterialPageRoute(builder: (_) => RoomView());
      case '/infobase/service':
        return MaterialPageRoute(builder: (_) => ServiceView());
      case '/profile/settings':
        return MaterialPageRoute(builder: (_) => SettingsView());
      case '/profile/followed_events':
        return MaterialPageRoute(builder: (_) => FollowedEventsView());
      case '/profile/created_events':
        return MaterialPageRoute(builder: (_) => CreatedEventsView());
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
          child: Text('ERROR'),
        ),
      );
    });
  }
}