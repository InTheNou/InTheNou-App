
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
  List<Tag> dummyTags = [Tag("ADMI",50), Tag("ADOF",50), Tag("AGRO",50), Tag
    ("ALEM",50), Tag("ANTR",50), Tag("ARTE",50), Tag("ASTR",50), Tag("BIND",50),
    Tag("BIOL",50), Tag("BOTA",50), Tag("CFIT",50), Tag("CHIN",50), Tag("CIAN",50)
    , Tag("CIBI",50), Tag("CIFI",50), Tag("CIIC",50), Tag("CIMA",50)];

}