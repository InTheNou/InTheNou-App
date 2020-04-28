import 'dart:io';
import 'package:InTheNou/assets/values.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class ApiConnection {
  final Dio _dio = Dio();

  static final ApiConnection _instance = ApiConnection._internal();

  factory ApiConnection() {
    return _instance;
  }

  ApiConnection._internal(){
    init();
  }

  Cookie session;
  List<Cookie> _cookies;

  Dio get dio => _dio;
  List<Cookie> get cookies => _cookies;
  PersistCookieJar _persistentCookies;

  /// Gets the Local Path to the Data directory of the app
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Creates the local directory for storing Cookies and the Session
  Future<Directory> get _localCookieDirectory async {
    final path = await _localPath;
    final Directory dir = new Directory('$path/cookies');
    await dir.create();
    return dir;
  }

  /// Initializes the Dio Http client for the API
  ///
  /// Loads u the cookies saved to file and saves the session if it exists.
  /// Also sets up some basic settings for the Http client including the
  /// [API_URL] that contains the base URL for the API. Lastly it uses
  /// interceptors to save the session when we receive it in the response of
  /// our requests.
  init() async{
    try {
      final Directory dir = await _localCookieDirectory;
      final cookiePath = dir.path;
      _persistentCookies = new PersistCookieJar(
          dir: '$cookiePath',
          persistSession: true);
      _cookies = _persistentCookies.loadForRequest(
          Uri.parse(API_URL));
      session = _cookies.firstWhere((c) => c.name == 'session', orElse: () => null);
      if(session != null ){
        debugPrint("Session Loaded");
      }
      _dio.interceptors.add(
          CookieManager(_persistentCookies)
      );
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate
      = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
      _dio.options = new BaseOptions(
        baseUrl: API_URL,
        responseType: ResponseType.json,
        connectTimeout: 10000,
        receiveTimeout: 100000,
      );
      _dio.interceptors.add(
          InterceptorsWrapper(
              onResponse:(Response response) {
                _cookies = _persistentCookies.loadForRequest(
                    Uri.parse(API_URL));
                session = cookies.firstWhere((c) => c.name == 'session', orElse: () => null);
                if(session != null){
                  _dio.options.headers['Cookie'] = session;
                }
                return response;
              }
          )
      );
    } catch (error, stacktrace) {
      print("Exception Initializing Dio: $error stackTrace: $stacktrace");
      return null;
    }
  }

  deleteSession(){
    _persistentCookies.deleteAll();
  }

  /// Returns the Session Cookie
  ///
  /// If ti exists it can just return it, if not then it will try to get it
  /// from the saved cookies.
  Future<Cookie> getSession() async{

    // Sometimes this gets called too early while it's being initialized so we
    // can wait for a bit
    while(_cookies == null){
      await Future.delayed(Duration(milliseconds: 100));
    }
    if(session == null){
      session = cookies.firstWhere((c) => c.name == 'session', orElse: () => null);
      if(session != null ){
        debugPrint("Session Loaded");
      }
    }
    return session;
  }
}