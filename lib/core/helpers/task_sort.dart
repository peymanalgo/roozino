import '../../data/models/task.dart';

List<Task> sortTasksSmartly(List<Task> tasks) {
  final sortedTasks = List<Task>.from(tasks);

  sortedTasks.sort((a, b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }

    final priorityComparison = _priorityWeight(b.priority)
        .compareTo(_priorityWeight(a.priority));

    if (priorityComparison != 0) {
      return priorityComparison;
    }

    final dueDateComparison = _compareDueDates(a.dueDate, b.dueDate);

    if (dueDateComparison != 0) {
      return dueDateComparison;
    }

    return b.createdAt.compareTo(a.createdAt);
  });

  return sortedTasks;
}

int _priorityWeight(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.normal:
      return 1;

    case TaskPriority.medium:
      return 2;

    case TaskPriority.high:
      return 3;
  }
}

int _compareDueDates(DateTime? first, DateTime? second) {
  if (first == null && second == null) {
    return 0;
  }

  if (first == null) {
    return 1;
  }

  if (second == null) {
    return -1;
  }

  return first.compareTo(second);
}
