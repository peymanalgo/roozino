import 'package:flutter/material.dart';

import '../../data/models/task.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        Text(
          'سلام 👋',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'برای امروز چه برنامه‌ای داری؟',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        const ProgressCard(),
        const SizedBox(height: 24),
        const SectionTitle(title: 'کارهای مهم', icon: Icons.priority_high),
        const SizedBox(height: 12),
        const TaskCard(
          title: 'ارسال گزارش پروژه',
          subtitle: 'امروز • ساعت ۱۰:۰۰',
          priority: TaskPriority.high,
        ),
        const TaskCard(
          title: 'تماس با مشتری',
          subtitle: 'امروز • ساعت ۱۲:۳۰',
          priority: TaskPriority.medium,
        ),
        const SizedBox(height: 20),
        const SectionTitle(title: 'برنامه امروز', icon: Icons.schedule),
        const SizedBox(height: 12),
        const TaskCard(
          title: '۳۰ دقیقه مطالعه',
          subtitle: 'امروز',
          priority: TaskPriority.normal,
        ),
        const TaskCard(
          title: 'خرید منزل',
          subtitle: 'امروز • ساعت ۱۸:۰۰',
          priority: TaskPriority.normal,
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CircularProgressIndicator(value: 0.60, strokeWidth: 7),
                  Text(
                    '۶۰٪',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'پیشرفت امروز',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text('۳ کار از ۵ کار انجام شده'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class TaskCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final TaskPriority priority;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.priority,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool completed = false;

  @override
  Widget build(BuildContext context) {
    Color priorityColor;

    switch (widget.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.normal:
        priorityColor = Colors.blueGrey;
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                value: completed,
                onChanged: (value) {
                  setState(() {
                    completed = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
