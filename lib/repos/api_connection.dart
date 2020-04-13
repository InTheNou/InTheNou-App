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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Directory> get _localCookieDirectory async {
    final path = await _localPath;
    final Directory dir = new Directory('$path/cookies');
    await dir.create();
    return dir;
  }

  init() async{
    try {
      final Directory dir = await _localCookieDirectory;
      final cookiePath = dir.path;
      _persistentCookies = new PersistCookieJar(
          dir: '$cookiePath',
          persistSession: true);
      _cookies = _persistentCookies.loadForRequest(
          Uri.parse(API_URL));
      session = cookies.firstWhere((c) => c.name == 'session', orElse: () => null);
      if(session != null ){
        debugPrint("SEssion Loaded");
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
        connectTimeout: 5000,
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
}