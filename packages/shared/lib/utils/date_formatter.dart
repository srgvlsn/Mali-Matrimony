import 'package:intl/intl.dart';

class DateFormatter {
  /// Format: 20/02/2002
  static String formatShortDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format: 14 February 1999
  static String formatFullDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('d MMMM yyyy').format(date);
  }

  /// Format: 20th February 2002, Wednesday
  static String formatLongDate(DateTime? date) {
    if (date == null) return 'N/A';

    String day = DateFormat('d').format(date);
    String suffix = _getDayOfMonthSuffix(int.parse(day));

    return DateFormat("'$day$suffix' MMMM yyyy, EEEE").format(date);
  }

  static String _getDayOfMonthSuffix(int dayNum) {
    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }
    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
