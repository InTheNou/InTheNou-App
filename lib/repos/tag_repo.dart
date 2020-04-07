import 'dart:convert' as convert;
import 'dart:io';
import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:http/http.dart' as http;


class TagRepo {

  static final TagRepo _instance = TagRepo._internal();
  var client = http.Client();

  factory TagRepo() {
    return _instance;
  }

  TagRepo._internal();

  Future<List<Tag>> getAllTags() async{
    return client.get(API_URL
        +"/App/Tags").then((response) {
      if (response.statusCode == HttpStatus.ok) {
        List<Tag> tagResults;
        List<dynamic> jsonResponse =
          convert.jsonDecode(response.body)["tags"];
        if(jsonResponse != null){
          tagResults = Tag.fromJsonToList(jsonResponse);
        }
        return tagResults;
      } else {
        return Future.error("Request failed with status: ${response
            .statusCode} please try again");
      }
    });
    return new List.of(dummyTags);
  }

  Map<Tag, bool> getAllTagsAsMap(){
    return new Map<Tag,bool>.fromIterable(dummyTags,
        key: (tag) => tag,
        value: (tag) => false
    );
  }

  // Debug stuff
  List<Tag> dummyTags = [Tag(1,"ADMI",0), Tag(2,"ADOF",0),
    Tag(3,"AGRO",0), Tag(4,"ALEM",0), Tag(5,"ANTR",0), Tag(6,"ARTE",0),
    Tag(7,"ASTR",0), Tag(8,"BIND",0), Tag(9,"BIOL",0), Tag(10,"BOTA",0),
    Tag(11,"CFIT",0), Tag(12,"CHIN",0), Tag(13,"CIAN",0), Tag(14,"CIBI",0),
    Tag(15,"CIFI",0), Tag(16,"CIIC",0), Tag(17,"CIMA",0)];

}