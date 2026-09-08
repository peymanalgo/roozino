import 'package:drift/drift.dart';

import '../database/app_database.dart' as db;
import '../models/task.dart' as model;
import 'task_repository.dart';

class DriftTaskRepository implements TaskRepository {
  final db.AppDatabase _database;

  DriftTaskRepository(this._database);

  @override
  Future<List<model.Task>> getAllTasks() async {
    final rows = await _database.select(_database.tasks).get();

    return rows.map((row) {
      return model.Task(
        id: row.id,
        title: row.title,
        description: row.description,
        isCompleted: row.isCompleted,
        priority: _priorityFromString(row.priority),
        dueDate: row.dueDate,
        createdAt: row.createdAt,
      );
    }).toList();
  }

  @override
  Future<model.Task?> getTaskById(int id) async {
    final query = _database.select(_database.tasks)
      ..where((table) => table.id.equals(id));

    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    return model.Task(
      id: row.id,
      title: row.title,
      description: row.description,
      isCompleted: row.isCompleted,
      priority: _priorityFromString(row.priority),
      dueDate: row.dueDate,
      createdAt: row.createdAt,
    );
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

  model.TaskPriority _priorityFromString(String value) {
    return model.TaskPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => model.TaskPriority.normal,
    );
  }
}
