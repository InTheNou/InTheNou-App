import 'package:InTheNou/EventFeed/FeedView.dart';
import 'package:InTheNou/EventFeed/PersonalFeedView.dart';
import 'package:InTheNou/Profile/ProfileView.dart';
import 'InformoationBase/InfoBaseCategoryView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;

void main() => runApp(InTheNouApp());

class InTheNouApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntheNou',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        primaryColorDark: Colors.indigo,

        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
          primarySwatch: Colors.indigo, accentColor: Colors.redAccent[400]
      ),
      home: HomePage(title: 'InTheNou'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  InfoBaseCategoryView informationBaseCategoryView;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
