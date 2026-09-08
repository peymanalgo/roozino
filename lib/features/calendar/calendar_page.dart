import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/helpers/persian_date.dart';
import '../../core/helpers/task_sort.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../widgets/add_task_sheet.dart';
import '../../widgets/edit_task_sheet.dart';

class CalendarPage extends StatefulWidget {
  final TaskRepository repository;
  final int refreshVersion;
  final VoidCallback onTasksChanged;

  const CalendarPage({
    super.key,
    required this.repository,
    required this.refreshVersion,
    required this.onTasksChanged,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Jalali _visibleMonth;
  late Jalali _selectedDate;

  late Future<List<Task>> _tasksFuture;

  static const List<String> _monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const List<String> _weekDayNames = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  @override
  void initState() {
    super.initState();

    final today = Jalali.now();

    _visibleMonth = Jalali(today.year, today.month, 1);

    _selectedDate = today;

    _loadTasks();
  }

  @override
  void didUpdateWidget(covariant CalendarPage oldWidget) {
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

  Future<void> _addTaskForSelectedDate() async {
    final wasCreated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return AddTaskSheet(
          repository: widget.repository,
          initialDueDate: _selectedDate.toDateTime(),
        );
      },
    );

    if (wasCreated == true && mounted) {
      widget.onTasksChanged();
    }
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
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف کار'),
          content: Text('آیا مطمئنی می‌خواهی «${task.title}» را حذف کنی؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
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

    try {
      await widget.repository.deleteTask(id);

      if (!mounted) {
        return;
      }

      widget.onTasksChanged();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('کار حذف شد')));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('حذف کار انجام نشد')));
    }
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

  void _goToPreviousMonth() {
    setState(() {
      if (_visibleMonth.month == 1) {
        _visibleMonth = Jalali(_visibleMonth.year - 1, 12, 1);
      } else {
        _visibleMonth = Jalali(_visibleMonth.year, _visibleMonth.month - 1, 1);
      }
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_visibleMonth.month == 12) {
        _visibleMonth = Jalali(_visibleMonth.year + 1, 1, 1);
      } else {
        _visibleMonth = Jalali(_visibleMonth.year, _visibleMonth.month + 1, 1);
      }
    });
  }

  void _goToToday() {
    final today = Jalali.now();

    setState(() {
      _visibleMonth = Jalali(today.year, today.month, 1);

      _selectedDate = today;
    });
  }

  int _daysInVisibleMonth() {
    final currentMonthStart = Jalali(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    ).toDateTime();

    final nextMonthStart = _visibleMonth.month == 12
        ? Jalali(_visibleMonth.year + 1, 1, 1).toDateTime()
        : Jalali(_visibleMonth.year, _visibleMonth.month + 1, 1).toDateTime();

    return nextMonthStart.difference(currentMonthStart).inDays;
  }

  int _firstDayOffset() {
    final firstDay = Jalali(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    ).toDateTime();

    return (firstDay.weekday + 1) % 7;
  }

  bool _isToday(Jalali date) {
    final today = Jalali.now();

    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isSelected(Jalali date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  bool _isSameGregorianDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<Task> _tasksForDate(List<Task> tasks, Jalali date) {
    final gregorianDate = date.toDateTime();

    return tasks.where((task) {
      final dueDate = task.dueDate;

      if (dueDate == null) {
        return false;
      }

      return _isSameGregorianDay(dueDate, gregorianDate);
    }).toList();
  }

  List<Task> _tasksForSelectedDate(List<Task> tasks) {
    final filteredTasks = _tasksForDate(tasks, _selectedDate);

    return sortTasksSmartly(filteredTasks);
  }

  bool _hasTasksOnDate(List<Task> tasks, Jalali date) {
    return _tasksForDate(tasks, date).isNotEmpty;
  }

  bool _hasOpenTasksOnDate(List<Task> tasks, Jalali date) {
    return _tasksForDate(tasks, date).any((task) => !task.isCompleted);
  }

  String _monthTitle() {
    final month = _monthNames[_visibleMonth.month - 1];

    final year = toPersianDigits(_visibleMonth.year.toString());

    return '$month $year';
  }

  String _selectedDateText() {
    return formatPersianDate(_selectedDate.toDateTime());
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

  Widget _buildWeekDays() {
    return Row(
      children: _weekDayNames.map((dayName) {
        return Expanded(
          child: Center(
            child: Text(
              dayName,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(List<Task> allTasks) {
    final dayCount = _daysInVisibleMonth();

    final offset = _firstDayOffset();

    final totalCells = offset + dayCount;

    final rowCount = (totalCells / 7).ceil();

    final visibleCellCount = rowCount * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleCellCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        if (index < offset) {
          return const SizedBox.shrink();
        }

        final dayNumber = index - offset + 1;

        if (dayNumber > dayCount) {
          return const SizedBox.shrink();
        }

        final date = Jalali(_visibleMonth.year, _visibleMonth.month, dayNumber);

        final isToday = _isToday(date);

        final isSelected = _isSelected(date);

        final hasTasks = _hasTasksOnDate(allTasks, date);

        final hasOpenTasks = _hasOpenTasksOnDate(allTasks, date);

        final colorScheme = Theme.of(context).colorScheme;

        Color? backgroundColor;
        Color? foregroundColor;
        Border? border;

        if (isSelected) {
          backgroundColor = colorScheme.primary;

          foregroundColor = colorScheme.onPrimary;
        } else if (isToday) {
          backgroundColor = colorScheme.primaryContainer;

          foregroundColor = colorScheme.onPrimaryContainer;

          border = Border.all(color: colorScheme.primary, width: 1.5);
        }

        final markerColor = isSelected
            ? colorScheme.onPrimary
            : hasOpenTasks
            ? colorScheme.primary
            : colorScheme.outline;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: border,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  toPersianDigits(dayNumber.toString()),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: foregroundColor,
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (hasTasks)
                  Positioned(
                    bottom: 5,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarWithTasks() {
    return FutureBuilder<List<Task>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        return Column(
          children: [
            _buildWeekDays(),
            const SizedBox(height: 10),
            _buildCalendarGrid(tasks),
          ],
        );
      },
    );
  }

  Widget _buildSelectedDayTasks() {
    return FutureBuilder<List<Task>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 10),
                  const Text('خطا در بارگذاری کارهای این روز'),
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
          );
        }

        final allTasks = snapshot.data ?? [];

        final tasks = _tasksForSelectedDate(allTasks);

        if (tasks.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.event_busy_outlined, size: 44),
                  const SizedBox(height: 12),
                  Text(
                    'برای ${_selectedDateText()} کاری ثبت نشده',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: tasks.map((task) {
            final description = task.description?.trim();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          _toggleTask(task, value);
                        },
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _editTask(task);
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 4, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
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
                                const SizedBox(height: 8),
                                Row(
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
                              ],
                            ),
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
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
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Text(
            'تقویم',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'برنامه‌ریزی روزها با تقویم شمسی',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'ماه بعد',
                        onPressed: _goToNextMonth,
                        icon: const Icon(Icons.chevron_right),
                      ),
                      Expanded(
                        child: Text(
                          _monthTitle(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        tooltip: 'ماه قبل',
                        onPressed: _goToPreviousMonth,
                        icon: const Icon(Icons.chevron_left),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _goToToday,
                    icon: const Icon(Icons.today_outlined),
                    label: const Text('رفتن به امروز'),
                  ),
                  const SizedBox(height: 12),
                  _buildCalendarWithTasks(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.event_available_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'روز انتخاب‌شده',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDateText(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('این علامت یعنی برای آن روز کار ثبت شده است'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _addTaskForSelectedDate,
              icon: const Icon(Icons.add_task),
              label: Text('افزودن کار برای ${_selectedDateText()}'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'کارهای این روز',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'برای ویرایش روی کار بزن یا از منوی سه‌نقطه استفاده کن.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          _buildSelectedDayTasks(),
        ],
      ),
    );
  }
}
