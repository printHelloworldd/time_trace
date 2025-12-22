import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'relational_database.g.dart';

// Defines the Activities table
class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();

  // Foreign Key on таблицу Categories
  IntColumn get categoryId => integer().references(Categories, #id)();

  IntColumn get hour => integer()(); // 0-23
  TextColumn get date => text()(); // '2024-12-18'
  IntColumn get timestamp => integer()(); // Unix timestamp for precise sorting
  IntColumn get createdAt => integer()();
}

// Defines the Categories table
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get colorValue => integer()(); // Stores color.value (ARGB)
  IntColumn get iconCodePoint =>
      integer().nullable()(); // Stores icon.codePoint
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// Database
@DriftDatabase(tables: [Categories, Activities])
class RelationalDatabase extends _$RelationalDatabase {
  RelationalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // Creates indexes
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_activities_date ON activities(date)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_activities_timestamp ON activities(timestamp)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_activities_category_id ON activities(category_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_activities_hour ON activities(hour)',
        );

        // Inserts default categories
        await _insertDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migrations when upgrading a schema version
      },
    );
  }

  // Inserts default categories after first launch
  Future<void> _insertDefaultCategories() async {
    final defaultCategories = [
      CategoriesCompanion(
        title: const Value('Useful'),
        colorValue: const Value(0xFF4CAF50), // Colors.green
        iconCodePoint: const Value(0xe1ce), // Icons.trending_up
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
      CategoriesCompanion(
        title: const Value('Necessity'),
        colorValue: const Value(0xFF2196F3), // Colors.blue
        iconCodePoint: const Value(0xe55c), // Icons.task_alt
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
      CategoriesCompanion(
        title: const Value('Useless'),
        colorValue: const Value(0xFFF44336), // Colors.red
        iconCodePoint: const Value(0xe1cd), // Icons.trending_down
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    ];

    for (final category in defaultCategories) {
      await into(categories).insert(category);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'activities.db'));
    return NativeDatabase(file);
  });
}
