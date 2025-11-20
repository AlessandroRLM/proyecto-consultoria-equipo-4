import 'package:intl/intl.dart';

class TransportTimeUtils {
  const TransportTimeUtils();

  DateTime parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) {
      return DateTime(0, 1, 1, 0, 0);
    }

    final second = parts[1];
    final ampmMatch =
        RegExp(r'(am|pm)', caseSensitive: false).firstMatch(second);
    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = 0;
    if (ampmMatch != null) {
      final ampm = ampmMatch.group(0)!.toLowerCase();
      final minuteStr = second.substring(0, ampmMatch.start).trim();
      minute = int.tryParse(minuteStr) ?? 0;
      if (ampm == 'pm' && hour < 12) {
        hour += 12;
      } else if (ampm == 'am' && hour == 12) {
        hour = 0;
      }
    } else {
      minute = int.tryParse(second) ?? 0;
    }

    return DateTime(0, 1, 1, hour, minute);
  }

  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}
