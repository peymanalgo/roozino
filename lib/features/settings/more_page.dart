import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'بیشتر',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const ListTile(
          leading: Icon(Icons.flag_outlined),
          title: Text('اهداف'),
        ),
        const ListTile(
          leading: Icon(Icons.bar_chart),
          title: Text('آمار و گزارش‌ها'),
        ),
        const ListTile(
          leading: Icon(Icons.dashboard_customize_outlined),
          title: Text('قالب‌ها'),
        ),
        const ListTile(
          leading: Icon(Icons.auto_awesome),
          title: Text('دستیار هوشمند'),
        ),
        const ListTile(
          leading: Icon(Icons.settings_outlined),
          title: Text('تنظیمات'),
        ),
      ],
    );
  }
}
