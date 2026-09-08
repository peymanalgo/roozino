import 'package:flutter/material.dart';

import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';

class EditTaskSheet extends StatefulWidget {
  final Task task;
  final TaskRepository repository;

  const EditTaskSheet({
    super.key,
    required this.task,
    required this.repository,
  });

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late final TextEditingController _titleController;

  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);

    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _dueDate = selectedDate;
    });
  }

  void _setToday() {
    final now = DateTime.now();

    setState(() {
      _dueDate = DateTime(now.year, now.month, now.day);
    });
  }

  void _clearDueDate() {
    setState(() {
      _dueDate = null;
    });
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year/$month/$day';
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();

    if (title.isEmpty || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedTask = Task(
        id: widget.task.id,
        title: title,
        description: widget.task.description,
        isCompleted: widget.task.isCompleted,
        priority: _priority,
        dueDate: _dueDate,
        createdAt: widget.task.createdAt,
      );

      await widget.repository.updateTask(updatedTask);

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ویرایش کار انجام نشد. دوباره تلاش کن.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('ویرایش کار', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'عنوان کار',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تاریخ انجام',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
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
                    onPressed: _pickDueDate,
                  ),
                  if (_dueDate != null)
                    ActionChip(
                      avatar: const Icon(Icons.close, size: 18),
                      label: const Text('حذف تاریخ'),
                      onPressed: _clearDueDate,
                    ),
                ],
              ),
              if (_dueDate != null) ...[
                const SizedBox(height: 10),
                Text('تاریخ انتخاب‌شده: ${_formatDate(_dueDate!)}'),
              ],
              const SizedBox(height: 20),
              Text('اولویت', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('عادی'),
                    selected: _priority == TaskPriority.normal,
                    onSelected: (_) {
                      setState(() {
                        _priority = TaskPriority.normal;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('متوسط'),
                    selected: _priority == TaskPriority.medium,
                    onSelected: (_) {
                      setState(() {
                        _priority = TaskPriority.medium;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('مهم'),
                    selected: _priority == TaskPriority.high,
                    onSelected: (_) {
                      setState(() {
                        _priority = TaskPriority.high;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _saveTask,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('ذخیره تغییرات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
