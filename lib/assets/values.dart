

//------------------- Enums and constants --------------------

enum FeedType{
  GeneralFeed,
  PersonalFeed,
  Detail
}

enum InfoBaseSearchType{
  Building,
  Room,
  Service,
  Floor
}

enum PhoneType{
  E,
  F,
  L,
  M
}

enum UserRole{
  Student,
  TeachingPersonnel,
  NonTeachingPersonnel
}

enum UserPrivilege{
  User,
  EventCreator,
  Moderator,
  Administrator
}

enum NotificationType{
  SmartNotification,
  DefaultNotification,
  RecommendationNotification,
  Alert
}

// Used when converting from json received from database for itype
enum InteractionType{
  Following,
  unfollowed,
  dismissed
}
// Used when converting from json received from database for reccomendstatus
enum RecommendationType{
  R,
  N
}

//Constants
const EVENTS_TO_FETCH = 100000;
const DEFAULT_NOTIFICATION_TIME = 5;
const SMART_NOTIFICATION_STATE = false;
const AVERAGE_WALKING_SPEED = 3.0;
const RECOMMENDATION_INTERVAL_MINUTES = 60;
const ASK_LOCATION_PERMISSION = true;
const WEIGHTED_SUM_THRESHOLD = 20;
const RELEVANCE_VALUE_FACTOR = 100;

const RECOMMENDATION_NOTIFICATION_ID = 0;
const ALERT_NOTIFICATION_ID = 1;

const NOTIFICATION_ID_START = 20;

const INITIAL_TAG_WEIGHT = 50;

const List<int> defaultNotificationTimes = [
  5, 10, 15, 20, 30
];

const API_URL = "https://inthenou.uprm.edu";

//Shared Preferences Keys
const DEFAULT_NOTIFICATION_KEY = "defaultNotificationTime";
const SMART_NOTIFICATION_KEY = "smartNotificationEnabled";
const USER_SESSION_KEY = "userSession";
const ASK_LOCATION_PERMISSION_KEY = "askLocation";
const SMART_NOTIFICATION_LIST = "smartNotificationList";
const DEFAULT_NOTIFICATION_LIST = "defaultNotificationList";
const NOTIFICATION_ID_KEY = "notificationId";
const LAST_RECOMMENDATION_DATE_KEY = "lastRecommendationDate";
const USER_KEY = "useraccount";

// Notification group IDs
const SMART_NOTIFICATION_GID = "smartNotificationList";
const DEFAULT_NOTIFICATION_GID = "smartNotificationList";
const RECOMMENDATION_NOTIFICATION_GID = "smartNotificationList";


