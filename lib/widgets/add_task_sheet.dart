import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../core/helpers/persian_date.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';

class AddTaskSheet extends StatefulWidget {
  final TaskRepository repository;
  final DateTime? initialDueDate;

  const AddTaskSheet({
    super.key,
    required this.repository,
    this.initialDueDate,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  TaskPriority _priority = TaskPriority.normal;
  TaskRecurrence _recurrence = TaskRecurrence.none;

  DateTime? _dueDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _dueDate = widget.initialDueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectPersianDate() async {
    final initialDate = _dueDate != null
        ? Jalali.fromDateTime(_dueDate!)
        : Jalali.now();

    final selectedDate = await showPersianDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: Jalali(1380, 1, 1),
      lastDate: Jalali(1450, 12, 29),
      helpText: 'انتخاب تاریخ',
      cancelText: 'انصراف',
      confirmText: 'تأیید',
      locale: const Locale('fa', 'IR'),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _dueDate = selectedDate.toDateTime();
    });
  }

  void _setToday() {
    final now = DateTime.now();

    setState(() {
      _dueDate = DateTime(now.year, now.month, now.day);
    });
  }

  void _clearDate() {
    setState(() {
      _dueDate = null;

      if (_recurrence != TaskRecurrence.none) {
        _recurrence = TaskRecurrence.none;
      }
    });
  }

  void _setRecurrence(TaskRecurrence recurrence) {
    setState(() {
      _recurrence = recurrence;

      if (recurrence != TaskRecurrence.none && _dueDate == null) {
        final now = DateTime.now();

        _dueDate = DateTime(now.year, now.month, now.day);
      }
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

  Future<void> _saveTask() async {
    if (_isSaving) {
      return;
    }

    final title = _titleController.text.trim();

    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('عنوان کار را وارد کن')));

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final task = Task(
        title: title,
        description: description.isEmpty ? null : description,
        priority: _priority,
        dueDate: _dueDate,
        recurrence: _recurrence,
        createdAt: DateTime.now(),
      );

      await widget.repository.createTask(task);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ذخیره کار انجام نشد')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'افزودن کار',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'عنوان کار',
                hintText: 'مثلاً خرید شیر',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'توضیحات',
                hintText: 'توضیحات بیشتر درباره این کار',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تاریخ',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.today, size: 18),
                  label: const Text('امروز'),
                  onPressed: _setToday,
                ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: const Text('انتخاب تاریخ'),
                  onPressed: _selectPersianDate,
                ),
                if (_dueDate != null)
                  ActionChip(
                    avatar: const Icon(Icons.close, size: 18),
                    label: const Text('حذف تاریخ'),
                    onPressed: _clearDate,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(formatPersianDate(_dueDate))),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'تکرار',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'برای کارهای منظم مثل ورزش، مطالعه یا پرداخت قبض',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskRecurrence.values.map((recurrence) {
                return ChoiceChip(
                  avatar: Icon(_recurrenceIcon(recurrence), size: 17),
                  label: Text(_recurrenceText(recurrence)),
                  selected: _recurrence == recurrence,
                  onSelected: (_) {
                    _setRecurrence(recurrence);
                  },
                );
              }).toList(),
            ),
            if (_recurrence != TaskRecurrence.none) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'این کار ${_recurrenceText(_recurrence)} تکرار می‌شود و از ${formatPersianDate(_dueDate)} شروع خواهد شد.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            Text(
              'اولویت',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values.map((priority) {
                return ChoiceChip(
                  label: Text(_priorityText(priority)),
                  selected: _priority == priority,
                  onSelected: (_) {
                    setState(() {
                      _priority = priority;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveTask,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_task),
                label: Text(_isSaving ? 'در حال ذخیره...' : 'افزودن'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
