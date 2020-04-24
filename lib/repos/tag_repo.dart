import 'package:InTheNou/assets/utils.dart';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/repos/api_connection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert' as convert;

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
    try{
      Response response = await dio.get(API_URL +"/App/Tags");
      List<Tag> tagResults;
      List<dynamic> jsonResponse = response.data["tags"];

      if(jsonResponse != null){
        tagResults = Tag.fromJsonToList(jsonResponse);
      }
      return tagResults;
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

  Future<bool> addTag(List<Tag> tags) async{
    try{
      Response response = await dio.post(API_URL +"/App/Tags/User/Add",
          data: convert.jsonEncode(Tag.toJsonList(tags)));
      List<Tag> tagResults;
      List<dynamic> jsonResponse = response.data["tags"];

      if(jsonResponse != null){
        tagResults = Tag.fromJsonToList(jsonResponse);
      }
      return tagResults.length == tags.length;
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
      Response response = await dio.post(API_URL +"/App/Tags/User/Remove",
        data: convert.jsonEncode(Tag.toJsonList(tags)));
    List<Tag> tagResults;
    List<dynamic> jsonResponse = response.data["tags"];

    if(jsonResponse != null){
    tagResults = Tag.fromJsonToList(jsonResponse);
    }
    return tagResults.length == tags.length;
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