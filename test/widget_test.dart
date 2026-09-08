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

  testWidgets('user can add a task from the UI', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    await tester.pumpWidget(RoozinoApp(database: database));

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));

    await tester.pumpAndSettle();

    expect(find.text('افزودن کار'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'خرید شیر');

    await tester.tap(find.widgetWithText(FilledButton, 'افزودن'));

    await tester.pumpAndSettle();

    expect(find.text('خرید شیر'), findsOneWidget);
  });

  testWidgets('user can edit a task from the UI', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    final repository = DriftTaskRepository(database);

    await repository.createTask(
      model.Task(
        title: 'کار اولیه',
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

    await tester.enterText(find.byType(TextField), 'کار ویرایش‌شده');

    await tester.tap(find.widgetWithText(FilledButton, 'ذخیره تغییرات'));

    await tester.pumpAndSettle();

    expect(find.text('کار ویرایش‌شده'), findsOneWidget);

    expect(find.text('کار اولیه'), findsNothing);

    final tasks = await repository.getAllTasks();

    expect(tasks.length, 1);

    expect(tasks.first.title, 'کار ویرایش‌شده');
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

    await tester.tap(find.byIcon(Icons.more_vert));

    await tester.pumpAndSettle();

    expect(find.text('حذف'), findsOneWidget);

    await tester.tap(find.text('حذف'));

    await tester.pumpAndSettle();

    expect(find.text('حذف کار'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'حذف'));

    await tester.pumpAndSettle();

    expect(find.text('کار برای حذف'), findsNothing);

    expect(find.text('کار حذف شد'), findsOneWidget);

    final tasks = await repository.getAllTasks();

    expect(tasks, isEmpty);
  });
}
