import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roozino/data/database/app_database.dart';
import 'package:roozino/data/models/task.dart' as model;
import 'package:roozino/data/repositories/drift_task_repository.dart';
import 'package:roozino/main.dart';

void main() {
  testWidgets('Roozino app loads successfully', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    await tester.pumpWidget(RoozinoApp(database: database));

    await tester.pumpAndSettle();

    expect(find.text('سلام 👋'), findsOneWidget);

    expect(find.text('هنوز کاری ثبت نکرده‌ای'), findsOneWidget);
  });

  testWidgets('user can add a task for today from the UI', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    final repository = DriftTaskRepository(database);

    await tester.pumpWidget(RoozinoApp(database: database));

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));

    await tester.pumpAndSettle();

    expect(find.text('افزودن کار'), findsOneWidget);

    final titleField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'عنوان کار',
    );

    final descriptionField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'توضیحات',
    );

    expect(titleField, findsOneWidget);

    expect(descriptionField, findsOneWidget);

    await tester.enterText(titleField, 'خرید شیر');

    await tester.enterText(descriptionField, 'دو بطری شیر کم‌چرب');

    await tester.tap(find.widgetWithText(ActionChip, 'امروز').last);

    await tester.pumpAndSettle();

    tester.testTextInput.hide();

    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'افزودن').last;

    await tester.ensureVisible(addButton);

    await tester.pumpAndSettle();

    await tester.tap(addButton);

    await tester.pumpAndSettle();

    final tasks = await repository.getAllTasks();

    expect(tasks.length, 1);

    expect(tasks.first.title, 'خرید شیر');

    expect(tasks.first.description, 'دو بطری شیر کم‌چرب');

    expect(tasks.first.dueDate, isNotNull);

    expect(tasks.first.recurrence, model.TaskRecurrence.none);

    final now = DateTime.now();

    final dueDate = tasks.first.dueDate!;

    expect(dueDate.year, now.year);

    expect(dueDate.month, now.month);

    expect(dueDate.day, now.day);
  });

  testWidgets('user can add a recurring task from the UI', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    final repository = DriftTaskRepository(database);

    await tester.pumpWidget(RoozinoApp(database: database));

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));

    await tester.pumpAndSettle();

    final titleField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'عنوان کار',
    );

    expect(titleField, findsOneWidget);

    await tester.enterText(titleField, 'مطالعه روزانه');

    tester.testTextInput.hide();

    await tester.pumpAndSettle();

    final dailyRecurrence = find.widgetWithText(ChoiceChip, 'هر روز').last;

    await tester.ensureVisible(dailyRecurrence);

    await tester.pumpAndSettle();

    await tester.tap(dailyRecurrence);

    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'افزودن').last;

    await tester.ensureVisible(addButton);

    await tester.pumpAndSettle();

    await tester.tap(addButton);

    await tester.pumpAndSettle();

    final tasks = await repository.getAllTasks();

    expect(tasks.length, 1);

    expect(tasks.first.title, 'مطالعه روزانه');

    expect(tasks.first.recurrence, model.TaskRecurrence.daily);

    expect(tasks.first.dueDate, isNotNull);
  });

  testWidgets('user can edit a task from the UI', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    final repository = DriftTaskRepository(database);

    await repository.createTask(
      model.Task(
        title: 'کار اولیه',
        description: 'توضیح اولیه',
        priority: model.TaskPriority.normal,
        createdAt: DateTime(2026, 9, 8, 10),
      ),
    );

    await tester.pumpWidget(RoozinoApp(database: database));

    await tester.pumpAndSettle();

    await tester.tap(find.text('کارها'));

    await tester.pumpAndSettle();

    expect(find.text('کار اولیه'), findsOneWidget);

    await tester.tap(find.text('کار اولیه'));

    await tester.pumpAndSettle();

    expect(find.text('ویرایش کار'), findsOneWidget);

    final titleField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'عنوان کار',
    );

    final descriptionField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'توضیحات',
    );

    expect(titleField, findsOneWidget);

    expect(descriptionField, findsOneWidget);

    await tester.enterText(titleField, 'کار ویرایش‌شده');

    await tester.enterText(descriptionField, 'توضیحات جدید');

    tester.testTextInput.hide();

    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(FilledButton, 'ذخیره تغییرات').last;

    await tester.ensureVisible(saveButton);

    await tester.pumpAndSettle();

    expect(saveButton, findsOneWidget);

    await tester.tap(saveButton);

    await tester.pumpAndSettle();

    final tasks = await repository.getAllTasks();

    expect(tasks.length, 1);

    expect(tasks.first.title, 'کار ویرایش‌شده');

    expect(tasks.first.description, 'توضیحات جدید');

    expect(tasks.first.recurrence, model.TaskRecurrence.none);
  });

  testWidgets('user can change task recurrence while editing', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    final repository = DriftTaskRepository(database);

    await repository.createTask(
      model.Task(
        title: 'ورزش',
        dueDate: DateTime(2026, 9, 8),
        recurrence: model.TaskRecurrence.none,
        createdAt: DateTime(2026, 9, 8, 10),
      ),
    );

    await tester.pumpWidget(RoozinoApp(database: database));

    await tester.pumpAndSettle();

    await tester.tap(find.text('کارها'));

    await tester.pumpAndSettle();

    expect(find.text('ورزش'), findsOneWidget);

    await tester.tap(find.text('ورزش'));

    await tester.pumpAndSettle();

    expect(find.text('ویرایش کار'), findsOneWidget);

    final weeklyRecurrence = find.widgetWithText(ChoiceChip, 'هر هفته').last;

    await tester.ensureVisible(weeklyRecurrence);

    await tester.pumpAndSettle();

    await tester.tap(weeklyRecurrence);

    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(FilledButton, 'ذخیره تغییرات').last;

    await tester.ensureVisible(saveButton);

    await tester.pumpAndSettle();

    await tester.tap(saveButton);

    await tester.pumpAndSettle();

    final tasks = await repository.getAllTasks();

    expect(tasks.length, 1);

    expect(tasks.first.title, 'ورزش');

    expect(tasks.first.recurrence, model.TaskRecurrence.weekly);

    expect(tasks.first.dueDate, isNotNull);
  });

  testWidgets('user can delete a task from the UI', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    final repository = DriftTaskRepository(database);

    await repository.createTask(
      model.Task(
        title: 'کار برای حذف',
        priority: model.TaskPriority.high,
        createdAt: DateTime(2026, 9, 8, 11),
      ),
    );

    await tester.pumpWidget(RoozinoApp(database: database));

    await tester.pumpAndSettle();

    await tester.tap(find.text('کارها'));

    await tester.pumpAndSettle();

    expect(find.text('کار برای حذف'), findsOneWidget);

    final menuButton = find.byIcon(Icons.more_vert);

    expect(menuButton, findsWidgets);

    await tester.tap(menuButton.last);

    await tester.pumpAndSettle();

    final deleteMenuItem = find.text('حذف').last;

    await tester.tap(deleteMenuItem);

    await tester.pumpAndSettle();

    expect(find.text('حذف کار'), findsOneWidget);

    final confirmDeleteButton = find.widgetWithText(FilledButton, 'حذف').last;

    await tester.tap(confirmDeleteButton);

    await tester.pumpAndSettle();

    final tasks = await repository.getAllTasks();

    expect(tasks, isEmpty);
  });

  testWidgets('completing a recurring task from UI creates next occurrence', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    final repository = DriftTaskRepository(database);

    final dueDate = DateTime.now();

    await repository.createTask(
      model.Task(
        title: 'کار تکرارشونده تست',
        dueDate: DateTime(dueDate.year, dueDate.month, dueDate.day),
        recurrence: model.TaskRecurrence.daily,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(RoozinoApp(database: database));

    await tester.pumpAndSettle();

    expect(find.text('کار تکرارشونده تست'), findsOneWidget);

    final checkbox = find.byType(Checkbox).first;

    await tester.tap(checkbox);

    await tester.pumpAndSettle();

    final tasks = await repository.getAllTasks();

    expect(tasks.length, 2);

    final completedTasks = tasks.where((task) => task.isCompleted);

    final openTasks = tasks.where((task) => !task.isCompleted);

    expect(completedTasks.length, 1);

    expect(openTasks.length, 1);

    final completedTask = completedTasks.single;
    final nextTask = openTasks.single;

    expect(completedTask.nextOccurrenceCreated, isTrue);

    expect(nextTask.title, 'کار تکرارشونده تست');

    expect(nextTask.recurrence, model.TaskRecurrence.daily);

    expect(nextTask.dueDate, isNotNull);

    final expectedNextDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    ).add(const Duration(days: 1));

    expect(nextTask.dueDate, expectedNextDate);
  });
}
