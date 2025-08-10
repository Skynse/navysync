import 'package:intl/intl.dart';

class DateTimeUtils {
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy hh:mm a');

  // Format date only
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // Format time only
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // Get relative time (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      final absDiff = difference.abs();
      if (absDiff.inDays > 0) {
        return '${absDiff.inDays} day${absDiff.inDays == 1 ? '' : 's'} ago';
      } else if (absDiff.inHours > 0) {
        return '${absDiff.inHours} hour${absDiff.inHours == 1 ? '' : 's'} ago';
      } else if (absDiff.inMinutes > 0) {
        return '${absDiff.inMinutes} minute${absDiff.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } else {
      if (difference.inDays > 0) {
        return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
      } else if (difference.inHours > 0) {
        return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
      } else if (difference.inMinutes > 0) {
        return 'in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'Now';
      }
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
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
    final startOfDay = DateTime(date.year, date.month, date.day);
    final weekday = date.weekday;
    return startOfDay.subtract(Duration(days: weekday - 1));
  }

  // Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    final weekday = date.weekday;
    return endOfDay.add(Duration(days: 7 - weekday));
  }
}
