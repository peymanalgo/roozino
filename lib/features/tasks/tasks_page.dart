import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'کارها',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const SmartListTile(
          icon: Icons.inbox_outlined,
          title: 'صندوق ورودی',
          count: 3,
        ),
        const SmartListTile(
          icon: Icons.today_outlined,
          title: 'امروز',
          count: 5,
        ),
        const SmartListTile(
          icon: Icons.event_outlined,
          title: 'آینده',
          count: 12,
        ),
        const SmartListTile(
          icon: Icons.warning_amber_rounded,
          title: 'عقب‌افتاده',
          count: 2,
        ),
        const SmartListTile(icon: Icons.flag_outlined, title: 'مهم', count: 4),
        const Divider(height: 40),
        Text(
          'پروژه‌ها',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const SmartListTile(icon: Icons.work_outline, title: 'کار', count: 8),
        const SmartListTile(icon: Icons.home_outlined, title: 'شخصی', count: 6),
        const SmartListTile(
          icon: Icons.fitness_center,
          title: 'سلامتی',
          count: 3,
        ),
      ],
    );
  }
}

class SmartListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const SmartListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text('$count', style: Theme.of(context).textTheme.titleMedium),
      onTap: () {},
    );
  }
}
