import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';

/// {@category Repo}
class TagRepo {

  static final TagRepo _instance = TagRepo._internal();
  final ApiConnection apiConnection = ApiConnection();

  factory TagRepo() {
    return _instance;
  }

  TagRepo._internal();

  /// Calls the API to get all [Tag]s in the system
  ///
  /// When this is called during Account Creation a Token is recieved from
  /// the API server and is the passed along thi call. Otherwise the Session
  /// stored locally will validate this call.
  Future<List<Tag>> getAllTags() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try{
      String token;
      if(prefs.getString("Token") != null){
        token = prefs.getString("Token");
      }
      Response response = await apiConnection.dio.get("/App/Tags",
      options: Options(
        headers: {
          "Token": "$token"
        }
      ));
      prefs.setString("Token", null);
      List<Tag> tagResults;

      if(response.data["tags"] != null){
        tagResults = Tag.fromJsonToList(response.data["tags"]);
      }
      return tagResults;
    } catch(error,stacktrace){
      if (error is DioError) {
        debugPrint("Exception: $error");
        if(error.response != null && error.response.statusCode == 401){
          return Future.error("Please Restart the Login Process.");
        }
        return Future.error(Utils.handleDioError(error, "Getting Tags") );
      } else {
        debugPrint("Exception: $error stackTrace: $stacktrace");
        return Future.error("Internal app error Getting Tags");
      }
    }
  }

  /// Calls the API to get add a [Tag] in the current user
  Future<bool> addTag(List<Tag> tags) async{
    try{
      Response response = await apiConnection.dio.post("/App/Tags/User/Add",
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

  /// Calls the API to get remove a [Tag] from the current user
  Future<bool> removeTag(List<Tag> tags) async{
    try{
      Response response = await apiConnection.dio.post("/App/Tags/User/Remove",
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