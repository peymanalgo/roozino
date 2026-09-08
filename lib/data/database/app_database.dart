import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  TextColumn get priority => text().withDefault(const Constant('normal'))();

  DateTimeColumn get dueDate => dateTime().nullable()();

  TextColumn get recurrence => text().withDefault(const Constant('none'))();

  BoolColumn get nextOccurrenceCreated =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'roozino'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.addColumn(tasks, tasks.recurrence);
        }

        if (from < 3) {
          await migrator.addColumn(tasks, tasks.nextOccurrenceCreated);
        }
      },
    );
  }
}
