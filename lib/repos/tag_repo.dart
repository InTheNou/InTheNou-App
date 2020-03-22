
import 'package:InTheNou/models/tag.dart';

class TagRepo {

  static final TagRepo _instance = TagRepo._internal();

  factory TagRepo() {
    return _instance;
  }

  TagRepo._internal();

  List<Tag> getAllTags(){
    return new List.of(dummyTags);
  }

  Map<Tag, bool> getAllTagsAsMap(){
    return new Map<Tag,bool>.fromIterable(dummyTags,
        key: (tag) => tag,
        value: (tag) => false
    );
  }

  // Debug stuff
  List<Tag> dummyTags = new List.generate(20, (index) =>
  new Tag("Tag$index", 20));


}