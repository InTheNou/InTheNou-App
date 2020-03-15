import 'package:InTheNou/RouteGenerator.dart';
import 'package:InTheNou/views/EventFeed/general_feed_view.dart';
import 'package:InTheNou/views/EventFeed/personal_feed_view.dart';
import 'package:InTheNou/views/InformoationBase/infobase_category_view.dart';
import 'package:InTheNou/views/Profile/profile_view.dart';
import 'package:InTheNou/assets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

void main() => runApp(InTheNouApp());

class InTheNouApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntheNou',
      theme: ThemeData(
          primarySwatch: primaryColor,
          accentColor: secondaryColor
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
//      home: HomePage(title: 'InTheNou'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with flux.StoreWatcherMixin {
  NavigationStore navigationStore;

  final List<Widget> _children = [
    PersonalFeedView(),
    GeneralFeedView(),
    InfoBaseCategoryView(),
    ProfileView()
  ];

  @override
  void initState() {
    super.initState();

    navigationStore = listenToStore(navigationToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[navigationStore.destinationIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: navigateToAction,
        currentIndex: navigationStore.destinationIndex, // index of navigation
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        selectedItemColor: Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: Color.fromARGB(80, 0, 0, 0),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: new Text("Feed"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: new Text('Search Events'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.business),
              title: Text('Profile')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile')
          )
        ],
      ),
    );
  }

}

class NavigationStore extends flux.Store {
  int _destinationIndex = 0;
  NavigationStore(){
    triggerOnAction(navigateToAction, (int c) {
      _destinationIndex = c;
    });
  }
  int get destinationIndex => _destinationIndex;
}
final flux.Action<int> navigateToAction = new flux.Action<int>();
final flux.StoreToken navigationToken = new flux.StoreToken(new NavigationStore
  ());
