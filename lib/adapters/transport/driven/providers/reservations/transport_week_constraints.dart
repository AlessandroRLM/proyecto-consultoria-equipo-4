class TransportWeekConstraints {
  const TransportWeekConstraints();

  bool isValidRange(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    if (startDate.isAtSameMomentAs(endDate)) {
      return true;
    }
    return !startDate.isAfter(endDate);
  }

  bool isWeekAllowed(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final today = _today();
    if (normalizedDate.isAtSameMomentAs(today)) {
      return true;
    }
    final minReservable = _minReservableReferenceDay();
    return !normalizedDate.isBefore(minReservable);
  }

  DateTime getMinReservableDate() {
    final today = _today();
    final todayWeekday = DateTime.now().weekday;
    final daysToNextMonday = (DateTime.monday - todayWeekday + 7) % 7;
    final nextMonday = today.add(
      Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday),
    );
    if (todayWeekday <= _cutoffWeekday) {
      return nextMonday;
    } else {
      return nextMonday.add(const Duration(days: 7));
    }
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _minReservableReferenceDay() {
    final today = _today();
    final todayWeekday = DateTime.now().weekday;
    final daysToNextMonday = (DateTime.monday - todayWeekday + 7) % 7;
    final nextMonday = today.add(
      Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday),
    );
    if (todayWeekday <= _cutoffWeekday) {
      return today;
    } else {
      return nextMonday;
    }
  }

  static const int _cutoffWeekday = 4;
}
