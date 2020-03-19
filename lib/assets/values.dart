import 'dart:math';

import 'package:InTheNou/models/floor.dart';

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
///
/// Helped method to convert the number [n] to its ordinal form.
/// As in:
///
///     ordinalNumber(1) = 1st
///     ordinalNumber(2) = 2nd
///     ordinalNumber(3) = 3rd
///     ordinalNumber(4) = 4th
///     ordinalNumber(5) = 5th
///
Floor ordinalNumber(int n){
  String suffix = ['th', 'st', 'nd', 'rd', 'th'][min(n % 10, 4)];
  if (11 <= (n % 100) && (n % 100) <= 13)
    suffix = 'th';
  return new Floor(n.toString() + suffix, n);
}

