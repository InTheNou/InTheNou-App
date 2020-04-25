import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';

class TagRepo {

  static final TagRepo _instance = TagRepo._internal();
  final ApiConnection apiConnection = ApiConnection();
  Dio dio;

  factory TagRepo() {
    return _instance;
  }

  TagRepo._internal(){
    dio = apiConnection.dio;
  }

  Future<List<Tag>> getAllTags() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try{
      String token;
      if(prefs.getString("Token") != null){
        token = prefs.getString("Token");
      }
      Response response = await dio.get("/App/Tags",
      options: Options(
        headers: {
          "Token": "$token"
        }
      ));
      prefs.setString("Token", null);
      List<Tag> tagResults;
      List<dynamic> jsonResponse = response.data["tags"];

      if(jsonResponse != null){
        tagResults = Tag.fromJsonToList(jsonResponse);
      }
      return tagResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        if(error.response.statusCode == 401){
          return Future.error("Please Restart the Login Process.");
        }
        return Future.error(Utils.handleDioError(error, "Getting Tags") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Tags");
      }
    }
  }

  Future<bool> addTag(List<Tag> tags) async{
    try{
      Response response = await dio.post("/App/Tags/User/Add",
          data: convert.jsonEncode({
            "tags": Tag.toSmallJsonList(tags)
          }));
      List<Tag> tagResults;
      List<dynamic> jsonResponse = response.data["tags"];

      if(jsonResponse != null){
        tagResults = Tag.fromJsonToList(jsonResponse);
      }
      return jsonResponse[0]["tid"] == tags[0].UID;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting Tags") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Tags");
      }
    }
  }

  Future<bool> removeTag(List<Tag> tags) async{
    try{
      Response response = await dio.post("/App/Tags/User/Remove",
        data: convert.jsonEncode({
          "tags": Tag.toSmallJsonList(tags)
        }));
      List<dynamic> jsonResponse = response.data["tags"];

      return jsonResponse[0]["tid"] == tags[0].UID;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        return Future.error(Utils.handleDioError(error, "Getting Tags") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Tags");
      }
    }
  }
}