import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format date
  static String formatDate(DateTime date, {String format = 'dd.MM.yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format time
  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime, {String format = 'dd.MM.yyyy HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    int difference = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: difference)));
  }

  // Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    int difference = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: difference)));
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return endOfDay(DateTime(date.year, date.month + 1, 0));
  }

  // Format duration
  static String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  // Get relative date string (Today, Tomorrow, Yesterday, or formatted date)
  static String getRelativeDateString(DateTime date, {String format = 'dd.MM.yyyy'}) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatDate(date, format: format);
    }
  }
}

