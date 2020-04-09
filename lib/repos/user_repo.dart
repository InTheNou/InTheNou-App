import 'dart:convert';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/event.dart';
import 'package:InTheNou/models/session.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/user.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:InTheNou/repos/events_repo.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UserRepo {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var client = http.Client();

  static final UserRepo _instance = UserRepo._internal();

  GoogleSignInAccount _userAccount;

  factory UserRepo() {
    return _instance;
  }

  UserRepo._internal();

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/contacts.readonly',
      "openid"
    ]
  );

  _launchURL(String URL) async {
    if (await canLaunch(URL)) {
      await launch(URL);
    } else {
      throw 'Could not launch $URL';
    }
  }
  ApiConnection apiConnection = ApiConnection();

  Future<bool> callAuthService() async {
//    _userAccount = await _googleSignIn.signIn();
//    print(_userAccount.toString());
//    var response = await client.get("/App/login");
//    debugPrint('Response body: ${response.body}');
//    RegExp reg = RegExp(r"(https:)(.*)(?=, 'OCAK')",multiLine: true);
//    String url = reg.stringMatch(response.body).split(RegExp(r"', "))[0];
//    url = url.replaceAll(RegExp(r'\\x3d'),"=");
//    url = url.replaceAll(RegExp(r'\\x26'),"&");
//    url = url.replaceAll(RegExp(r'\\/'),r"/");
//    print(url);
    String url = "https://25.128.255.65/App/login";

    HttpClient client = new HttpClient();

//    HttpClientRequest clientRequest =
//    await client.getUrl(Uri.parse("https://inthenou.uprm.edu/Dashboard/Users/Delegated"));
//    Cookie session = Cookie("session", ""
//        ".eJyVTstqw0AQ-xUzZ1O8r9ld_0aPJYSZ2ZnE4ObgjQ8l5N-70C8oOkhCAukFV9up37XD-vWC6TkIvrV3uinM8HmKDGPnvv9Mfbs9tE3b4wMu7_k_5cs8Zg7td1ifx6nDbQ1WcM2YiES1cW4-VlSvUQKjoFtSTiQRgyteAzUUx9UtmAeK4tCZ1XLL3rRVjowlGCWyZNVVKzJCcktBl-IiPofAjIiRgo-RfSkpjc_Xs-vx9ybC-xc6olK-.Xo6a0A.D5QLQR_3kCcEaIPYdG-WAqaGd3A");
//
//    session.domain = ".inthenou.uprm.edu";
//    session.path = "/";
//    clientRequest.cookies.add(session);
//    HttpClientResponse clientResponse = await clientRequest.close();
//    clientResponse.transform(utf8.decoder).listen((body) {
//      var document = convert.jsonDecode(body);
//      print(document);
//    });
    Dio dio =  apiConnection.dio;

//    _launchURL(url);
    // Present the dialog to the user

//    return FlutterWebAuth.authenticate(url: url,
//        callbackUrlScheme: "inthenou").then((value) async{
//          var uri = Uri.parse(value);
//          print(uri);
//          print(uri.queryParameters['uid']);
//          print(uri.queryParameters['newAccount']);
//          print(uri.queryParameters["session"]);
////          print(convert.jsonDecode(uri.queryParameters["session"]));
//          var cj = CookieJar();
//          List<Cookie> results = cj.loadForRequest(Uri.parse(url));
//          print(results);
//          await dio.get(url).then((value) {
//            print(value);
//            print(value.headers.toString());
//            print(apiConnection.cookies);
//            print(apiConnection.session);
//
//          }).catchError((e){
//            print(e);
//          });
//        return Uri.parse(value).queryParameters['newAccount'] == "True";
//        });

    return true;
  }


  /// Check if there is a Session saved locally.
  /// IF there isn't one then just send null so the user goes to Login
  /// If there is one, check with he backend to see if its valid. In the
  /// case that it is valid then the user can be routed to the app,
  /// otherwise the user is routed to the login to re-auth.
  Future<Session> getSession() async{
    final SharedPreferences prefs = await _prefs;
//    _googleSignIn.signInSilently().then((GoogleSignInAccount acc) {
//      if(acc == null){
//
//      } else{
//        _userAccount = acc;
//      }
//    });
    return Future.delayed(Duration(seconds: 3)).then((onValue) {
      Session session = Session(prefs.getString(USER_SESSION_KEY));
      if(session.value == null){
        return null;
      }
      return checkSession(session).then((value) {
        return value ? session : null;
      });
    });
  }

  /// Calls the API and check if the session is not expired
  /// [session] being the locally saved Flask Session cookie
  Future<bool> checkSession(Session session){
    return Future.delayed(Duration(seconds: 1)).then((onValue) {
      return true;
    });
  }


  /// Calls the backend to get the user information after the login redirect.
  /// Also, the session returned by the backend is saved locally.
  Future<User> getUserInfo() async{
    return dummyUser;
  }

  Future<User> createUser(UserRole role, List<Tag> tags) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(USER_SESSION_KEY, "totally valid session");

    return Future.delayed(Duration(seconds: 3)).then((onValue) {
      dummyUser = new User("Alguien", "Importante",
          "alguien.importante@upr.edu",role, tags, UserPrivilege.EventCreator);
      return dummyUser;
    });
  }

  User getUser(){
    return dummyUser;
  }

  /// Removes the Session from the local storage so that the user may sign
  /// back in.
  Future<bool> logOut() async{
    final SharedPreferences prefs = await _prefs;
    return Future.delayed(Duration(seconds: 1)).then((onValue) {
      prefs.setString(USER_SESSION_KEY, null);
      dummyUser = null; // debug
      return true;
    });
//    _googleSignIn.signOut();
  }

  Future<List<Event>> getFollowedEvents(int skipEvents, int numEvents) async{
    return client.get(API_URL
        +"/App/Events/Following//uid=4/offset=$skipEvents/limit=$numEvents")
        .then((response) {
          if (response.statusCode == HttpStatus.ok) {
            List<Event> eventResults = new List();
            List jsonResponse = convert.jsonDecode(response.body)["events"];
            if(jsonResponse != null){
              jsonResponse.forEach((element) {
                eventResults.add(Event.resultFromJson(element,
                    isFollowed: true));
              });
            }
            return eventResults;
          } else {
            return Future.error("Request failed with status: ${response
                .statusCode} please try again");
          }
        });
//    return getFollowedEventsFromSecretPlace();
  }

  Future<List<Event>> getCreatedEvents(int skipEvents, int numEvents) async{
    return client.get(API_URL
        +"/App/Events/Created//uid=4/offset=$skipEvents/limit=$numEvents")
        .then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Event> eventResults = new List();
        List jsonResponse = convert.jsonDecode(response.body)["events"];
        if(jsonResponse != null){
          jsonResponse.forEach((element) {
            eventResults.add(Event.resultFromJson(element));
          });
        }
        return eventResults;
      } else {
        return Future.error("Request failed with status: ${response
            .statusCode} please try again");
      }
    });
    return getFollowedEventsFromSecretPlace2();
  }
  bool requestDeleteEvents(Event event){
    _eventRepo.deleteEvent(event);
    return true;
  }
  Future<List<Tag>> getUserTags() async{
    return dummyUser.tags;
  }

  // debug stuff
  static User dummyUser = new User("Alguien", "Importante",
      "alguien.importante@upr.edu",UserRole.Student,
      [Tag(1,"ADMI",INITIAL_TAG_WEIGHT), Tag(2,"ADOF",INITIAL_TAG_WEIGHT),
        Tag(3,"AGRO",INITIAL_TAG_WEIGHT), Tag(4,"ALEM",INITIAL_TAG_WEIGHT),
        Tag(5,"ANTR",INITIAL_TAG_WEIGHT)],
      UserPrivilege.EventCreator);

  EventsRepo _eventRepo = new EventsRepo();
  Future<List<Event>> getFollowedEventsFromSecretPlace() async{
    return _eventRepo.getGenEvents(0,10000000).then((List<Event> value) {
      return value.where((element){
        return element.followed;
      }).toList();
    });

  }
  Future<List<Event>> getFollowedEventsFromSecretPlace2() async{
    return _eventRepo.getGenEvents(0,10000000).then((List<Event> value) {
      return value.where((element){
        return element.creator == "alguien.importante@upr.edu"
            && element.startDateTime.isAfter(DateTime.now());
      }).toList();
    });
  }

}