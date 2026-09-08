import 'dart:math' as math;

import 'package:shamsi_date/shamsi_date.dart';

import '../../data/models/task.dart';

DateTime? calculateNextTaskDueDate(Task task) {
  final dueDate = task.dueDate;

  if (dueDate == null) {
    return null;
  }

  switch (task.recurrence) {
    case TaskRecurrence.none:
      return null;

    case TaskRecurrence.daily:
      return _dateOnly(dueDate.add(const Duration(days: 1)));

    case TaskRecurrence.weekly:
      return _dateOnly(dueDate.add(const Duration(days: 7)));

    case TaskRecurrence.monthly:
      return _nextJalaliMonth(dueDate);
  }
}

DateTime _nextJalaliMonth(DateTime dueDate) {
  final current = Jalali.fromDateTime(dueDate);

  final targetYear = current.month == 12 ? current.year + 1 : current.year;

  final targetMonth = current.month == 12 ? 1 : current.month + 1;

  final maximumDay = _jalaliMonthLength(targetYear, targetMonth);

  final targetDay = math.min(current.day, maximumDay);

  return Jalali(targetYear, targetMonth, targetDay).toDateTime();
}

int _jalaliMonthLength(int year, int month) {
  final start = Jalali(year, month, 1).toDateTime();

  final next = month == 12
      ? Jalali(year + 1, 1, 1).toDateTime()
      : Jalali(year, month + 1, 1).toDateTime();

  return next.difference(start).inDays;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
