import 'package:InTheNou/EventFeed/general_feed_view.dart';
import 'package:InTheNou/EventFeed/personal_feed_view.dart';
import 'package:InTheNou/Profile/profile_view.dart';
import 'package:InTheNou/RouteGenerator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

import 'InformoationBase/infobase_category_view.dart';

void main() => runApp(InTheNouApp());

class InTheNouApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntheNou',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        primaryColorDark: Colors.indigo,
        // This is the theme of your application.
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
          primarySwatch: Colors.indigo, accentColor: Colors.redAccent[400]
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

    // Demonstrates using the default handler, which just calls setState().
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
