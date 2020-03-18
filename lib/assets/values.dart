
enum FeedType{
  GeneralFeed,
  PersonalFeed
}

String feedTypeString(FeedType feedType) =>
    feedType == FeedType.PersonalFeed ? "PersonalFeed" : "GeneralFeed";

enum PhoneType{
  C,
  E,
  F,
  L,
  M
}

String telephoneTypeString(PhoneType telephoneType) {
  switch (telephoneType){
    case PhoneType.C:
      return "C";
      break;
    case PhoneType.E:
      return "E";
      break;
    case PhoneType.F:
      return "P";
      break;
    case PhoneType.L:
      return "L";
      break;
    case PhoneType.M:
      return "M";
      break;
  }
}
