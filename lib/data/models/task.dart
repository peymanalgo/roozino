enum TaskPriority { normal, medium, high }

enum TaskRecurrence { none, daily, weekly, monthly }

class Task {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? dueDate;
  final TaskRecurrence recurrence;
  final bool nextOccurrenceCreated;
  final DateTime createdAt;

  const Task({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.normal,
    this.dueDate,
    this.recurrence = TaskRecurrence.none,
    this.nextOccurrenceCreated = false,
    required this.createdAt,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
    TaskRecurrence? recurrence,
    bool? nextOccurrenceCreated,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      recurrence: recurrence ?? this.recurrence,
      nextOccurrenceCreated:
          nextOccurrenceCreated ?? this.nextOccurrenceCreated,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
