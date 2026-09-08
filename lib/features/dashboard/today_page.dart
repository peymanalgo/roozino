import 'package:flutter/material.dart';

import '../../core/helpers/persian_date.dart';
import '../../core/helpers/task_sort.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

class TodayPage extends StatefulWidget {
  final TaskRepository repository;
  final int refreshVersion;
  final VoidCallback onTasksChanged;

  const TodayPage({
    super.key,
    required this.repository,
    required this.refreshVersion,
    required this.onTasksChanged,
  });

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didUpdateWidget(covariant TodayPage oldWidget) {
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

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isDueToday(Task task) {
    final dueDate = task.dueDate;

    if (dueDate == null) {
      return false;
    }

    final today = _dateOnly(DateTime.now());

    final taskDate = _dateOnly(dueDate);

    return taskDate == today;
  }

  bool _isOverdue(Task task) {
    final dueDate = task.dueDate;

    if (dueDate == null || task.isCompleted) {
      return false;
    }

    final today = _dateOnly(DateTime.now());

    final taskDate = _dateOnly(dueDate);

    return taskDate.isBefore(today);
  }

  List<Task> _prepareTodayTasks(List<Task> tasks) {
    final todayTasks = tasks.where((task) {
      return _isDueToday(task) || _isOverdue(task);
    }).toList();

    return sortTasksSmartly(todayTasks);
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

  IconData _priorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.normal:
        return Icons.flag_outlined;

      case TaskPriority.medium:
        return Icons.flag_outlined;

      case TaskPriority.high:
        return Icons.flag;
    }
  }

  String _dateStatusText(Task task) {
    if (_isOverdue(task)) {
      return 'عقب‌افتاده';
    }

    if (_isDueToday(task)) {
      return 'امروز';
    }

    return formatPersianDate(task.dueDate);
  }

  int _countOverdueTasks(List<Task> tasks) {
    return tasks.where(_isOverdue).length;
  }

  int _countOpenTodayTasks(List<Task> tasks) {
    return tasks.where((task) {
      return _isDueToday(task) && !task.isCompleted;
    }).length;
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
                    'سلام 👋',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'امروز روی چه چیزی تمرکز می‌کنی؟',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'کارهای امروز',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'کارهای امروز و کارهای عقب‌افتاده',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 12),
                          const Text('خطا در بارگذاری کارها'),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                _loadTasks();
                              });
                            },
                            child: const Text('تلاش دوباره'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final allTasks = snapshot.data ?? [];

              final tasks = _prepareTodayTasks(allTasks);

              if (tasks.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64),
                          SizedBox(height: 16),
                          Text(
                            'هنوز کاری ثبت نکرده‌ای',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'برای امروز کاری نداری. با دکمه + یک کار برای امروز بساز.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final overdueCount = _countOverdueTasks(tasks);

              final todayOpenCount = _countOpenTodayTasks(tasks);

              return SliverMainAxisGroup(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.today_outlined, size: 18),
                            label: Text('$todayOpenCount کار امروز'),
                          ),
                          if (overdueCount > 0)
                            Chip(
                              avatar: const Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                              ),
                              label: Text('$overdueCount عقب‌افتاده'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    sliver: SliverList.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        final description = task.description?.trim();

                        final isOverdue = _isOverdue(task);

                        final isDueToday = _isDueToday(task);

                        return Card(
                          child: CheckboxListTile(
                            value: task.isCompleted,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              _toggleTask(task, value);
                            },
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _priorityIcon(task.priority),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'اولویت: ${_priorityText(task.priority)}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(_dateStatusText(task)),
                                      ],
                                    ),
                                    if (isOverdue)
                                      const Chip(
                                        visualDensity: VisualDensity.compact,
                                        avatar: Icon(
                                          Icons.warning_amber_rounded,
                                          size: 16,
                                        ),
                                        label: Text('عقب‌افتاده'),
                                      ),
                                    if (isDueToday && !task.isCompleted)
                                      const Chip(
                                        visualDensity: VisualDensity.compact,
                                        avatar: Icon(Icons.today, size: 16),
                                        label: Text('برای امروز'),
                                      ),
                                  ],
                                ),
                                if (task.dueDate != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    formatPersianDate(task.dueDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
