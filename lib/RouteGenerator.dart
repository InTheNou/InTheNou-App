import 'package:InTheNou/Account/account_creation_view.dart';
import 'package:InTheNou/Account/login_view.dart';
import 'package:InTheNou/EventFeed/event_detail_view.dart';
import 'package:InTheNou/EventFeed/general_feed_view.dart';
import 'package:InTheNou/EventFeed/personal_feed_view.dart';
import 'package:InTheNou/InformoationBase/building_view.dart';
import 'package:InTheNou/InformoationBase/floor_view.dart';
import 'package:InTheNou/InformoationBase/infobase_category_view.dart';
import 'package:InTheNou/InformoationBase/infobase_search_view.dart';
import 'package:InTheNou/InformoationBase/room_view.dart';
import 'package:InTheNou/InformoationBase/service_view.dart';
import 'package:InTheNou/Profile/profile_view.dart';
import 'package:InTheNou/main.dart';
import "package:flutter/material.dart";

class RouteGenerator{

  static Route<dynamic> generateRoute(RouteSettings settings){
    switch (settings.name){
      case "/":
        return MaterialPageRoute(builder: (_) => HomePage());
      case "/login":
        return MaterialPageRoute(builder: (_) => LoginView());
      case "/accountcreation":
        return MaterialPageRoute(builder: (_) => AccountCreationView());
      case "/personalfeed":
        return MaterialPageRoute(builder: (_) => PersonalFeedView());
      case '/generalFeed':
        return MaterialPageRoute(builder: (_) => GeneralFeedView());
      case "/eventdetail":
        return MaterialPageRoute(builder: (_) => EventDetailView());
      case '/infobase':
        return MaterialPageRoute(builder: (_) => InfoBaseCategoryView());
      case '/infobase/search':
        return MaterialPageRoute(builder: (_) => InfoBaseSearchView());
      case '/infobase/building':
        return MaterialPageRoute(builder: (_) => BuildingView());
      case '/infobase/floor':
        return MaterialPageRoute(builder: (_) => FloorView());
      case '/infobase/room':
        return MaterialPageRoute(builder: (_) => RoomView());
      case '/infobase/service':
        return MaterialPageRoute(builder: (_) => ServiceView());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfileView());
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