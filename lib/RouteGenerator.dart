import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/dialog_manager.dart';
import 'package:InTheNou/home_page.dart';
import 'package:InTheNou/start_up_view.dart';
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
import 'package:InTheNou/views/Profile/debug_settings_view.dart';
import 'package:InTheNou/views/Profile/dismissed_events_view.dart';
import 'package:InTheNou/views/Profile/followed_events_view.dart';
import 'package:InTheNou/views/Profile/history_events_view.dart';
import 'package:InTheNou/views/Profile/my_tags_view.dart';
import 'package:InTheNou/views/Profile/settings_view.dart';
import 'package:InTheNou/views/widgets/crashy_view.dart';
import 'package:InTheNou/views/widgets/notification_view.dart';
import "package:flutter/material.dart";

/// Utility class for managing the routing between views
class RouteGenerator{

  static Route<dynamic> generateRoute(RouteSettings settings){
    var args = settings.arguments;

    return MaterialPageRoute(
        settings: settings,
        builder: (_){
          switch (settings.name){
            case "/":
              return DialogManager(child: StartUpView());
            case "/home":
              return DialogManager(child: HomePage());
            case "/login":
              return DialogManager(child: LoginView());
            case "/accountcreation":
              return DialogManager(child: AccountCreationView());
            case "/eventdetail":
              if (args is int) {
                return EventDetailView(args);
              }
              return _errorRoute();
            case '/create_event':
              return EventCreationView();
            case '/infobase/search':
              if (args is InfoBaseType) {
                return InfoBaseSearchView(args);
              }
              return _errorRoute();
            case '/infobase/building':
              return BuildingView();
            case '/infobase/floor':
              return FloorView();
            case '/infobase/room':
              return RoomView();
            case '/infobase/service':
              return ServiceView();
            case '/profile/settings':
              return SettingsView();
            case '/profile/settings/debug':
              return DebugSettingsView();
            case '/profile/followed_events':
              return FollowedEventsView();
            case '/profile/event_history':
              return HistoryEventsView();
            case '/profile/dismissed_events':
              return DismissedEventsView();
            case '/profile/my_tags':
              return MyTagsView();
            case '/profile/created_events':
              return CreatedEventsView();
            case "crashy":
              return CrashyView();
            case "notifications":
              return NotificationView();
            default:
              return _errorRoute();
          }
        }
    );
  }

  /// The default Error route shown if there was a mistake moving from one
  /// view to another
  static Widget _errorRoute() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Oops something happened trying to get you to your '
              'destination.',
            style: TextStyle(
              fontSize: 20
            ),
          ),
        )
      ),
    );
  }
}