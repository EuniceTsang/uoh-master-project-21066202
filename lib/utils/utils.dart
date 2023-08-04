class Utils {
  static String dateTimeToString(DateTime dateTime) {
    return dateTime.toString();
  }

  static String? dateTimeToStringNullable(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return dateTime.toString();
  }

  static DateTime? stringToDateTimeNullable(String? dateTimeString) {
    if (dateTimeString == null) {
      return null;
    }
    return DateTime.parse(dateTimeString);
  }

  static String formatTimeDifference(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}
