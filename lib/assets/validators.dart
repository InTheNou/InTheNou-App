import 'package:InTheNou/assets/values.dart';
import 'package:InTheNou/models/tag.dart';
import 'package:InTheNou/models/website.dart';
import 'package:validators/validators.dart';

class Validators {

  static String  validateTitle(String title){
    if (title.isEmpty){
      return "Title must be provided";
    } else if(title.trim().length < 3){
      return "Title is too short";
    } else if(title.length > 50){
      return "Title is too long";
    }
    return null;
  }

  static String  validateDescription(String description){
    if (description.isEmpty){
      return "Description must be provided";
    } else if(description.trim().length < 3){
      return "Description is too short";
    } else if(description.length > 400){
      return "Description is too long";
    }
    return null;
  }

  static String validateImage(String image) {
    if(image.isNotEmpty){
      if(image.trim().length < 3){
        return "Image link is too short";
      } else if(!Uri.parse(image.trim()).isAbsolute || !isURL(image.trim(),
          protocols: ['http', 'https'])){
        return "Invalid Image link";
      } else if(image.length > 400){
        return "Image link is too long";
      }
    }
    return null;
  }

  static String validateDate(DateTime date, DateTime startDate,
      DateTime endDate){
    if(date == null){
      return "Insert Date";
    } else if(date.isBefore(DateTime.now())){
      return "Event Start in the past";
    }
    if(endDate != null){
      if (startDate.isAfter(endDate)){
        return "Event Start After Event End";
      } else if(endDate.difference(startDate).inHours > 168){
        return "Event Duration too long";
      } else if(endDate.difference(startDate).inMinutes < 5){
        return "Event Duration too short";
      }
    }
    return null;
  }

  static String  validateWebsiteDescription(String website){
    if(website.isNotEmpty){
      if(website.trim().length < 3){
        return "Website Description is too short";
      } else if(website.length > 50){
        return "Website Description is too long";
      }
    }
    return null;
  }

  static String  validateWebsiteLink(String link){
    if (link.isEmpty){
      return "URL is required";
    } else if(link.trim().length < 3){
      return "URL is too short";
    } else if(!Uri.parse(link.trim()).isAbsolute || !isURL(link.trim(), protocols:
    ['http', 'https'])){
      return "Invalid URL";
    }  else if(link.length > 400){
      return "URL is too long";
    }
    return null;
  }

  static bool validateWebsiteQuantity(List<Website> website){
    return website.length < 10;
  }

  static bool validateDuplicateWebsite(List<Website> websites,
      Website newWebsite){
    return websites.contains(newWebsite);
  }

  static bool validateSelectedTags(List<Tag> tags){
    if (tags.isEmpty){
      return false;
    } else if(tags.length < 3){
      return false;
    } else if(tags.length > 10){
      return false;
    }
    return true;
  }

  static bool validateUserRole(UserRole role){
    return role != null;
  }

  static bool validateCreationTags(List<Tag> tags){
    if (tags.isEmpty){
      return false;
    } else if(tags.length < 5){
      return false;
    } else if(tags.length > 5){
      return false;
    }
    return true;
  }

}