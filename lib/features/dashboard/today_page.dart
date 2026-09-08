import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

class TodayPage extends StatefulWidget {
  final TaskRepository repository;
  final int refreshVersion;

  const TodayPage({
    super.key,
    required this.repository,
    required this.refreshVersion,
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

    await widget.repository.setTaskCompleted(id, isCompleted);

    if (!mounted) {
      return;
    }

    setState(() {
      _loadTasks();
    });
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

  String _formatDueDate(DateTime? date) {
    if (date == null) {
      return 'بدون تاریخ';
    }

    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year/$month/$day';
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
                    'کارهای من',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
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

              final tasks = snapshot.data ?? [];

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
                            'برای افزودن اولین کار، دکمه + را بزن.',
                            textAlign: TextAlign.center,
                          ),
                        ],
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
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_priorityIcon(task.priority), size: 16),
                                const SizedBox(width: 4),
                                Text(_priorityText(task.priority)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(_formatDueDate(task.dueDate)),
                              ],
                            ),
                          ],
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
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
