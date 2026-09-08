import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();

  Future<Task?> getTaskById(int id);

  Future<int> createTask(Task task);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(int id);

  Future<void> setTaskCompleted(int id, bool isCompleted);

  Future<void> setTaskCompletion(Task task, bool isCompleted);
}
