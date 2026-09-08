import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roozino/data/database/app_database.dart';
import 'package:roozino/data/models/task.dart' as model;
import 'package:roozino/data/repositories/drift_task_repository.dart';

void main() {
  late AppDatabase database;
  late DriftTaskRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftTaskRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates and reads a task', () async {
    final task = model.Task(
      title: 'خرید نان',
      description: 'از نانوایی محله',
      priority: model.TaskPriority.high,
      dueDate: DateTime(2026, 9, 8),
      createdAt: DateTime(2026, 9, 8, 10),
    );

    final id = await repository.createTask(task);

    final savedTask = await repository.getTaskById(id);

    expect(savedTask, isNotNull);
    expect(savedTask!.title, 'خرید نان');
    expect(savedTask.description, 'از نانوایی محله');
    expect(savedTask.priority, model.TaskPriority.high);
    expect(savedTask.isCompleted, false);
  });

  test('updates a task', () async {
    final id = await repository.createTask(
      model.Task(
        title: 'کار اولیه',
        createdAt: DateTime(2026, 9, 8),
      ),
    );

    final existingTask = await repository.getTaskById(id);

    final updatedTask = existingTask!.copyWith(
      title: 'کار ویرایش‌شده',
      priority: model.TaskPriority.medium,
    );

    await repository.updateTask(updatedTask);

    final savedTask = await repository.getTaskById(id);

    expect(savedTask!.title, 'کار ویرایش‌شده');
    expect(savedTask.priority, model.TaskPriority.medium);
  });

  test('marks a task as completed', () async {
    final id = await repository.createTask(
      model.Task(
        title: 'تماس با مشتری',
        createdAt: DateTime(2026, 9, 8),
      ),
    );

    await repository.setTaskCompleted(id, true);

    final savedTask = await repository.getTaskById(id);

    expect(savedTask!.isCompleted, true);
  });

  test('deletes a task', () async {
    final id = await repository.createTask(
      model.Task(
        title: 'کار قابل حذف',
        createdAt: DateTime(2026, 9, 8),
      ),
    );

    await repository.deleteTask(id);

    final deletedTask = await repository.getTaskById(id);

    expect(deletedTask, isNull);
  });

  test('returns all tasks', () async {
    await repository.createTask(
      model.Task(
        title: 'کار اول',
        createdAt: DateTime(2026, 9, 8, 8),
      ),
    );

    await repository.createTask(
      model.Task(
        title: 'کار دوم',
        createdAt: DateTime(2026, 9, 8, 9),
      ),
    );

    final tasks = await repository.getAllTasks();

    expect(tasks.length, 2);
  });
}