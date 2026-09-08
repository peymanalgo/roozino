import '../tasks/tasks_page.dart';
import 'today_page.dart';

import 'package:flutter/material.dart';

import '../calendar/calendar_page.dart';
import '../focus/focus_page.dart';
import '../settings/more_page.dart';
import '../../widgets/add_task_sheet.dart';

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
