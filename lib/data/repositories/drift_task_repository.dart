import 'package:drift/drift.dart';

import '../../core/helpers/task_recurrence.dart';
import '../database/app_database.dart' as db;
import '../models/task.dart' as model;
import 'task_repository.dart';

class DriftTaskRepository implements TaskRepository {
  final db.AppDatabase _database;

  DriftTaskRepository(this._database);

  @override
  Future<List<model.Task>> getAllTasks() async {
    final rows = await _database.select(_database.tasks).get();

    return rows.map(_mapRowToTask).toList();
  }

  @override
  Future<model.Task?> getTaskById(int id) async {
    final query = _database.select(_database.tasks)
      ..where((table) => table.id.equals(id));

    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _mapRowToTask(row);
  }

  @override
  Future<int> createTask(model.Task task) {
    return _database
        .into(_database.tasks)
        .insert(
          db.TasksCompanion.insert(
            title: task.title,
            description: Value(task.description),
            isCompleted: Value(task.isCompleted),
            priority: Value(task.priority.name),
            dueDate: Value(task.dueDate),
            recurrence: Value(task.recurrence.name),
            nextOccurrenceCreated: Value(task.nextOccurrenceCreated),
            createdAt: task.createdAt,
          ),
        );
  }

  @override
  Future<void> updateTask(model.Task task) async {
    final id = task.id;

    if (id == null) {
      throw ArgumentError('Task id is required for update.');
    }

    await (_database.update(
      _database.tasks,
    )..where((table) => table.id.equals(id))).write(
      db.TasksCompanion(
        title: Value(task.title),
        description: Value(task.description),
        isCompleted: Value(task.isCompleted),
        priority: Value(task.priority.name),
        dueDate: Value(task.dueDate),
        recurrence: Value(task.recurrence.name),
        nextOccurrenceCreated: Value(task.nextOccurrenceCreated),
        createdAt: Value(task.createdAt),
      ),
    );
  }

  @override
  Future<void> deleteTask(int id) async {
    await (_database.delete(
      _database.tasks,
    )..where((table) => table.id.equals(id))).go();
  }

  @override
  Future<void> setTaskCompleted(int id, bool isCompleted) async {
    await (_database.update(_database.tasks)
          ..where((table) => table.id.equals(id)))
        .write(db.TasksCompanion(isCompleted: Value(isCompleted)));
  }

  @override
  Future<void> setTaskCompletion(model.Task task, bool isCompleted) async {
    final id = task.id;

    if (id == null) {
      throw ArgumentError('Task id is required for completion.');
    }

    if (!isCompleted) {
      await setTaskCompleted(id, false);
      return;
    }

    if (task.recurrence == model.TaskRecurrence.none || task.dueDate == null) {
      await setTaskCompleted(id, true);
      return;
    }

    if (task.nextOccurrenceCreated) {
      await setTaskCompleted(id, true);
      return;
    }

    final nextDueDate = calculateNextTaskDueDate(task);

    if (nextDueDate == null) {
      await setTaskCompleted(id, true);
      return;
    }

    await _database.transaction(() async {
      await (_database.update(
        _database.tasks,
      )..where((table) => table.id.equals(id))).write(
        const db.TasksCompanion(
          isCompleted: Value(true),
          nextOccurrenceCreated: Value(true),
        ),
      );

      await _database
          .into(_database.tasks)
          .insert(
            db.TasksCompanion.insert(
              title: task.title,
              description: Value(task.description),
              isCompleted: const Value(false),
              priority: Value(task.priority.name),
              dueDate: Value(nextDueDate),
              recurrence: Value(task.recurrence.name),
              nextOccurrenceCreated: const Value(false),
              createdAt: DateTime.now(),
            ),
          );
    });
  }

  model.Task _mapRowToTask(db.Task row) {
    return model.Task(
      id: row.id,
      title: row.title,
      description: row.description,
      isCompleted: row.isCompleted,
      priority: _priorityFromString(row.priority),
      dueDate: row.dueDate,
      recurrence: _recurrenceFromString(row.recurrence),
      nextOccurrenceCreated: row.nextOccurrenceCreated,
      createdAt: row.createdAt,
    );
  }

  model.TaskPriority _priorityFromString(String value) {
    return model.TaskPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => model.TaskPriority.normal,
    );
  }

  model.TaskRecurrence _recurrenceFromString(String value) {
    return model.TaskRecurrence.values.firstWhere(
      (recurrence) => recurrence.name == value,
      orElse: () => model.TaskRecurrence.none,
    );
  }
}
