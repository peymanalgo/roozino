import 'package:flutter/material.dart';

import '../../core/helpers/persian_date.dart';
import '../../core/helpers/task_sort.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../widgets/edit_task_sheet.dart';

enum TaskFilter { all, today, important, completed }

class TasksPage extends StatefulWidget {
  final TaskRepository repository;
  final int refreshVersion;
  final VoidCallback onTasksChanged;

  const TasksPage({
    super.key,
    required this.repository,
    required this.refreshVersion,
    required this.onTasksChanged,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late Future<List<Task>> _tasksFuture;

  TaskFilter _selectedFilter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didUpdateWidget(covariant TasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _loadTasks();
    }
  }

  void _loadTasks() {
    _tasksFuture = widget.repository.getAllTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _loadTasks();
    });

    await _tasksFuture;
  }

  Future<void> _toggleTask(Task task, bool isCompleted) async {
    final id = task.id;

    if (id == null) {
      return;
    }

    await widget.repository.setTaskCompletion(task, isCompleted);

    if (!mounted) {
      return;
    }

    widget.onTasksChanged();
  }

  Future<void> _editTask(Task task) async {
    final wasUpdated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return EditTaskSheet(task: task, repository: widget.repository);
      },
    );

    if (wasUpdated == true && mounted) {
      widget.onTasksChanged();
    }
  }

  Future<void> _deleteTask(Task task) async {
    final id = task.id;

    if (id == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف کار'),
          content: Text('آیا از حذف «${task.title}» مطمئنی؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await widget.repository.deleteTask(id);

    if (!mounted) {
      return;
    }

    widget.onTasksChanged();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('کار حذف شد')));
  }

  List<Task> _applyFilter(List<Task> tasks) {
    List<Task> filteredTasks;

    switch (_selectedFilter) {
      case TaskFilter.all:
        filteredTasks = tasks;
        break;

      case TaskFilter.today:
        final now = DateTime.now();

        filteredTasks = tasks.where((task) {
          final dueDate = task.dueDate;

          if (dueDate == null) {
            return false;
          }

          return dueDate.year == now.year &&
              dueDate.month == now.month &&
              dueDate.day == now.day;
        }).toList();
        break;

      case TaskFilter.important:
        filteredTasks = tasks
            .where(
              (task) => task.priority == TaskPriority.high && !task.isCompleted,
            )
            .toList();
        break;

      case TaskFilter.completed:
        filteredTasks = tasks.where((task) => task.isCompleted).toList();
        break;
    }

    return sortTasksSmartly(filteredTasks);
  }

  String _emptyMessage() {
    switch (_selectedFilter) {
      case TaskFilter.all:
        return 'هنوز کاری ثبت نشده';

      case TaskFilter.today:
        return 'برای امروز کاری ثبت نشده';

      case TaskFilter.important:
        return 'کار مهمی باقی نمانده';

      case TaskFilter.completed:
        return 'هنوز کاری تکمیل نشده';
    }
  }

  String _priorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.normal:
        return 'عادی';

      case TaskPriority.medium:
        return 'متوسط';

      case TaskPriority.high:
        return 'مهم';
    }
  }

  String _recurrenceText(TaskRecurrence recurrence) {
    switch (recurrence) {
      case TaskRecurrence.none:
        return 'بدون تکرار';

      case TaskRecurrence.daily:
        return 'هر روز';

      case TaskRecurrence.weekly:
        return 'هر هفته';

      case TaskRecurrence.monthly:
        return 'هر ماه';
    }
  }

  IconData _recurrenceIcon(TaskRecurrence recurrence) {
    switch (recurrence) {
      case TaskRecurrence.none:
        return Icons.block_outlined;

      case TaskRecurrence.daily:
        return Icons.today_outlined;

      case TaskRecurrence.weekly:
        return Icons.view_week_outlined;

      case TaskRecurrence.monthly:
        return Icons.calendar_month_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'کارها',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'همه کارهایت را یک‌جا مدیریت کن',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'مرتب‌سازی هوشمند فعال است',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('همه'),
                          selected: _selectedFilter == TaskFilter.all,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = TaskFilter.all;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('امروز'),
                          selected: _selectedFilter == TaskFilter.today,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = TaskFilter.today;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('مهم'),
                          selected: _selectedFilter == TaskFilter.important,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = TaskFilter.important;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('تکمیل‌شده'),
                          selected: _selectedFilter == TaskFilter.completed,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = TaskFilter.completed;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Task>>(
            future: _tasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          _loadTasks();
                        });
                      },
                      child: const Text('تلاش دوباره'),
                    ),
                  ),
                );
              }

              final allTasks = snapshot.data ?? [];

              final tasks = _applyFilter(allTasks);

              if (tasks.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _emptyMessage(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: SliverList.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    final description = task.description?.trim();

                    return Card(
                      child: ListTile(
                        onTap: () {
                          _editTask(task);
                        },
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            _toggleTask(task, value);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (description != null &&
                                description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  task.priority == TaskPriority.high
                                      ? Icons.flag
                                      : Icons.flag_outlined,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text('اولویت: ${_priorityText(task.priority)}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(formatPersianDate(task.dueDate)),
                                ),
                              ],
                            ),
                            if (task.recurrence != TaskRecurrence.none) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    _recurrenceIcon(task.recurrence),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'تکرار: ${_recurrenceText(task.recurrence)}',
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          tooltip: 'گزینه‌های کار',
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editTask(task);
                            }

                            if (value == 'delete') {
                              _deleteTask(task);
                            }
                          },
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined),
                                    SizedBox(width: 8),
                                    Text('ویرایش'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline),
                                    SizedBox(width: 8),
                                    Text('حذف'),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
