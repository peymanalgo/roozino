import 'package:flutter/material.dart';

import 'security_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Text(
          'بیشتر',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'تنظیمات و اطلاعات روزینو',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 38,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'روزینو',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'مدیریت ساده و روزانه کارها',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'تنظیمات',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.security_rounded),
            title: const Text('امنیت'),
            subtitle: const Text('قفل برنامه، رمز و بیومتریک'),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SecurityPage()),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'اطلاعات برنامه',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('نسخه برنامه'),
                subtitle: Text('1.0.0'),
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const ListTile(
                leading: Icon(Icons.language_rounded),
                title: Text('زبان'),
                subtitle: Text('فارسی'),
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const ListTile(
                leading: Icon(Icons.calendar_month_outlined),
                title: Text('تقویم'),
                subtitle: Text('شمسی'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome_outlined, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'امکانات بیشتر مثل تمرکز، عادت‌ها، پروژه‌ها، '
                    'یادآوری پیشرفته و همگام‌سازی در نسخه‌های بعدی روزینو '
                    'اضافه می‌شوند.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
