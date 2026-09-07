import 'package:flutter/material.dart';

void main() {
  runApp(const RoozinoApp());
}

class RoozinoApp extends StatelessWidget {
  const RoozinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'روزینو',
      locale: const Locale('fa', 'IR'),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF6750A4),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6750A4),
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    TodayPage(),
    TasksPage(),
    CalendarPage(),
    FocusPage(),
    MorePage(),
  ];

  void openAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddTaskSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: selectedIndex, children: pages),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTask,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'امروز',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'کارها',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'تقویم',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'تمرکز',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'بیشتر'),
        ],
      ),
    );
  }
}

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

enum TaskPriority { normal, medium, high }

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

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      icon: Icons.calendar_month,
      title: 'تقویم',
      subtitle: 'تقویم شمسی و برنامه‌ریزی زمانی در این بخش قرار می‌گیرد.',
    );
  }
}

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      icon: Icons.timer,
      title: 'تمرکز',
      subtitle: 'پومودورو، جلسات تمرکز و عادت‌ها در این بخش قرار می‌گیرند.',
    );
  }
}

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

class PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PlaceholderPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

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
