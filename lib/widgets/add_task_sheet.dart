import 'package:flutter/material.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'کار جدید',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: 'مثلاً فردا به علی زنگ بزن',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.today, size: 18),
                label: const Text('امروز'),
                onPressed: () {},
              ),
              ActionChip(
                avatar: const Icon(Icons.schedule, size: 18),
                label: const Text('زمان'),
                onPressed: () {},
              ),
              ActionChip(
                avatar: const Icon(Icons.flag_outlined, size: 18),
                label: const Text('اولویت'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_task),
              label: const Text('افزودن کار'),
            ),
          ),
        ],
      ),
    );
  }
}
