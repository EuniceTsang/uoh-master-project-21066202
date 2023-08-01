class Constants {
  //route
  static const routeLaunch = '/launch';
  static const routeBaseNavigation = '/base-navigation';
  static const routeLogin = '/login';
  static const routeRegister = '/register';
  static const routeTask = '/task';
  static const routeHistory = '/history';
  static const routeDictionary = '/dictionary';
  static const routeReading = '/reading';
  static const routeForumThread = '/forum-thread';
}

class TaskFields {
  static const collection = 'task';
  static const user_id = 'user_id';
  static const type = 'type';
  static const target = 'target';
  static const current = 'current';
  static const points = 'points';
  static const last_update_time = 'last_update_time';
}

class ArticleFields {
  static const collection = 'article';
  static const url = 'url';
  static const image_url = 'image_url';
  static const title = 'title';
  static const check_time = 'check_time';
  static const user_id = 'user_id';
}
