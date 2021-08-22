import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isWithinRange(DateTimeRange range, [bool inclusive = true]) {
    bool result = false;

    if (isAfter(range.start) && isBefore(range.end)) {
      result = true;
    }

    if (inclusive) {
      if (isAtSameMomentAs(range.start) || isAtSameMomentAs(range.end)) {
        result = true;
      }
    }

    return result;
  }
}

extension DurationExtension on Duration {
  String format() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return '${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
