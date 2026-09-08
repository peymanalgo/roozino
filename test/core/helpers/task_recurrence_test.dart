import 'package:flutter_test/flutter_test.dart';
import 'package:roozino/core/helpers/task_recurrence.dart';
import 'package:roozino/data/models/task.dart';
import 'package:shamsi_date/shamsi_date.dart';

void main() {
  group('calculateNextTaskDueDate', () {
    test('returns null when recurrence is none', () {
      final task = Task(
        title: 'کار ساده',
        dueDate: DateTime(2026, 9, 8),
        recurrence: TaskRecurrence.none,
        createdAt: DateTime(2026, 9, 8),
      );

      final result = calculateNextTaskDueDate(task);

      expect(result, isNull);
    });

    test('returns null when due date is null', () {
      final task = Task(
        title: 'کار بدون تاریخ',
        recurrence: TaskRecurrence.daily,
        createdAt: DateTime(2026, 9, 8),
      );

      final result = calculateNextTaskDueDate(task);

      expect(result, isNull);
    });

    test('daily recurrence moves one day forward', () {
      final task = Task(
        title: 'مطالعه',
        dueDate: DateTime(2026, 9, 8),
        recurrence: TaskRecurrence.daily,
        createdAt: DateTime(2026, 9, 8),
      );

      final result = calculateNextTaskDueDate(task);

      expect(result, DateTime(2026, 9, 9));
    });

    test('weekly recurrence moves seven days forward', () {
      final task = Task(
        title: 'ورزش',
        dueDate: DateTime(2026, 9, 8),
        recurrence: TaskRecurrence.weekly,
        createdAt: DateTime(2026, 9, 8),
      );

      final result = calculateNextTaskDueDate(task);

      expect(result, DateTime(2026, 9, 15));
    });

    test('monthly recurrence follows Jalali calendar', () {
      final dueDate = Jalali(1405, 1, 10).toDateTime();

      final task = Task(
        title: 'پرداخت',
        dueDate: dueDate,
        recurrence: TaskRecurrence.monthly,
        createdAt: dueDate,
      );

      final result = calculateNextTaskDueDate(task);

      expect(result, isNotNull);

      final jalali = Jalali.fromDateTime(result!);

      expect(jalali.year, 1405);

      expect(jalali.month, 2);

      expect(jalali.day, 10);
    });

    test('monthly recurrence clamps invalid Jalali day', () {
      final dueDate = Jalali(1405, 6, 31).toDateTime();

      final task = Task(
        title: 'گزارش ماهانه',
        dueDate: dueDate,
        recurrence: TaskRecurrence.monthly,
        createdAt: dueDate,
      );

      final result = calculateNextTaskDueDate(task);

      expect(result, isNotNull);

      final jalali = Jalali.fromDateTime(result!);

      expect(jalali.year, 1405);

      expect(jalali.month, 7);

      expect(jalali.day, 30);
    });

    test('monthly recurrence moves to next Jalali year', () {
      final dueDate = Jalali(1405, 12, 29).toDateTime();

      final task = Task(
        title: 'مرور سالانه',
        dueDate: dueDate,
        recurrence: TaskRecurrence.monthly,
        createdAt: dueDate,
      );

      final result = calculateNextTaskDueDate(task);

      expect(result, isNotNull);

      final jalali = Jalali.fromDateTime(result!);

      expect(jalali.year, 1406);

      expect(jalali.month, 1);

      expect(jalali.day, 29);
    });
  });
}
