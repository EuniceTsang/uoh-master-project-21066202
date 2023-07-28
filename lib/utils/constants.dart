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

class WordFields {
  static const collection = 'word';
  static const word = 'word';
  static const pof = 'pof';
  static const definition = 'definition';
  static const check_time = 'check_time';
  static const user_id = 'user_id';
}

class ArticleFields {
  static const collection = 'article';
  static const url = 'url';
  static const image_url = 'image_url';
  static const title = 'title';
  static const check_time = 'check_time';
  static const user_id = 'user_id';
}

class ThreadFields {
  static const collection = 'thread';
  static const thread_id = 'thread_id';
  static const title = 'title';
  static const body = 'body';
  static const post_time = 'post_time';
  static const user_id = 'user_id';
  static const liked_users = 'liked_users';
}

class CommentFields {
  static const collection = 'comment';
  static const thread_id = 'thread_id';
  static const user_id = 'user_id';
  static const body = 'body';
  static const liked_users = 'liked_users';
  static const post_time = 'post_time';
}