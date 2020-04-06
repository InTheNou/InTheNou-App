
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
  List<Tag> dummyTags = [Tag(1,"ADMI",0), Tag(2,"ADOF",0),
    Tag(3,"AGRO",0), Tag(4,"ALEM",0), Tag(5,"ANTR",0), Tag(6,"ARTE",0),
    Tag(7,"ASTR",0), Tag(8,"BIND",0), Tag(9,"BIOL",0), Tag(10,"BOTA",0),
    Tag(11,"CFIT",0), Tag(12,"CHIN",0), Tag(13,"CIAN",0), Tag(14,"CIBI",0),
    Tag(15,"CIFI",0), Tag(16,"CIIC",0), Tag(17,"CIMA",0)];

}