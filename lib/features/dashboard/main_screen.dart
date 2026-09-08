import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/drift_task_repository.dart';
import '../../widgets/add_task_sheet.dart';
import '../calendar/calendar_page.dart';
import '../settings/more_page.dart';
import '../tasks/tasks_page.dart';
import 'today_page.dart';

class MainScreen extends StatefulWidget {
  final AppDatabase? database;

  const MainScreen({super.key, this.database});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  int _taskRefreshVersion = 0;

  late final AppDatabase _database;
  late final DriftTaskRepository _taskRepository;

  @override
  void initState() {
    super.initState();

    _database = widget.database ?? AppDatabase();
    _taskRepository = DriftTaskRepository(_database);
  }

  @override
  void dispose() {
    if (widget.database == null) {
      _database.close();
    }

    super.dispose();
  }

  void _notifyTasksChanged() {
    setState(() {
      _taskRefreshVersion++;
    });
  }

  Future<void> openAddTask() async {
    final wasCreated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return AddTaskSheet(repository: _taskRepository);
      },
    );

    if (wasCreated == true && mounted) {
      _notifyTasksChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TodayPage(
        repository: _taskRepository,
        refreshVersion: _taskRefreshVersion,
        onTasksChanged: _notifyTasksChanged,
      ),
      TasksPage(
        repository: _taskRepository,
        refreshVersion: _taskRefreshVersion,
        onTasksChanged: _notifyTasksChanged,
      ),
      CalendarPage(
        repository: _taskRepository,
        refreshVersion: _taskRefreshVersion,
        onTasksChanged: _notifyTasksChanged,
      ),
      const MorePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: selectedIndex, children: pages),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddTask,
        icon: const Icon(Icons.add),
        label: const Text('کار جدید'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
            selectedIcon: Icon(Icons.today_rounded),
            label: 'امروز',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'کارها',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'تقویم',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_rounded),
            selectedIcon: Icon(Icons.more_rounded),
            label: 'بیشتر',
          ),
        ],
      ),
    );
  }
}
