import 'package:drift/drift.dart';
import 'package:time_trace/model/category_mapper.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/model/activity_mapper.dart';
import 'package:time_trace/model/activity_model.dart';
import 'package:time_trace/service/relational_database.dart';

class ActivityService {
  final RelationalDatabase database;

  ActivityService({required this.database});

  Future<int> addActivity(ActivityModel model) async {
    final companion = ActivityMapper.toCompanion(model);
    return await database.into(database.activities).insert(companion);
  }

  Future<bool> updateActivity(ActivityModel model) async {
    final entity = ActivityMapper.toEntity(model);
    return await database.update(database.activities).replace(entity);
  }

  Future<int> deleteActivity(int id) async {
    return await (database.delete(database.activities)
      ..where((a) => a.id.equals(id))).go();
  }

  Future<ActivityModel?> getActivityById(int id) async {
    final query = database.select(database.activities).join([
      leftOuterJoin(
        database.categories,
        database.categories.id.equalsExp(database.activities.categoryId),
      ),
    ])..where(database.activities.id.equals(id));

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    final activityEntity = result.readTable(database.activities);
    final categoryEntity = result.readTable(database.categories);

    return ActivityMapper.fromEntity(
      activityEntity,
      CategoryMapper.fromEntity(categoryEntity),
    );
  }

  Future<List<ActivityModel>> getActivitiesForDate(DateTime date) async {
    final dateStr = _formatDate(date);

    final query =
        database.select(database.activities).join([
            leftOuterJoin(
              database.categories,
              database.categories.id.equalsExp(database.activities.categoryId),
            ),
          ])
          ..where(database.activities.date.equals(dateStr))
          ..orderBy([OrderingTerm.asc(database.activities.hour)]);

    final results = await query.get();

    return results.map((row) {
      final activityEntity = row.readTable(database.activities);
      final categoryEntity = row.readTable(database.categories);
      return ActivityMapper.fromEntity(
        activityEntity,
        CategoryMapper.fromEntity(categoryEntity),
      );
    }).toList();
  }

  Future<List<ActivityModel>> getTodayActivities() async {
    return await getActivitiesForDate(DateTime.now());
  }

  Future<List<ActivityModel>> getActivitiesByCategory({
    required DateTime date,
    required int categoryId,
  }) async {
    final dateStr = _formatDate(date);

    final query =
        database.select(database.activities).join([
            leftOuterJoin(
              database.categories,
              database.categories.id.equalsExp(database.activities.categoryId),
            ),
          ])
          ..where(database.activities.date.equals(dateStr))
          ..where(database.activities.categoryId.equals(categoryId))
          ..orderBy([OrderingTerm.asc(database.activities.hour)]);

    final results = await query.get();

    return results.map((row) {
      final activityEntity = row.readTable(database.activities);
      final categoryEntity = row.readTable(database.categories);
      return ActivityMapper.fromEntity(
        activityEntity,
        CategoryMapper.fromEntity(categoryEntity),
      );
    }).toList();
  }

  Future<Map<CategoryModel, int>> getCategoryStatsForDate(DateTime date) async {
    final dateStr = _formatDate(date);

    final query = database.select(database.activities).join([
      leftOuterJoin(
        database.categories,
        database.categories.id.equalsExp(database.activities.categoryId),
      ),
    ])..where(database.activities.date.equals(dateStr));

    final results = await query.get();

    // Groups
    final stats = <int, int>{}; // categoryId -> count
    final categoriesMap = <int, CategoryModel>{}; // categoryId -> CategoryModel

    for (final row in results) {
      final activityEntity = row.readTable(database.activities);
      final categoryEntity = row.readTable(database.categories);
      final categoryId = activityEntity.categoryId;

      stats[categoryId] = (stats[categoryId] ?? 0) + 1;
      if (!categoriesMap.containsKey(categoryId)) {
        categoriesMap[categoryId] = CategoryMapper.fromEntity(categoryEntity);
      }
    }

    return Map.fromEntries(
      stats.entries.map((e) => MapEntry(categoriesMap[e.key]!, e.value)),
    );
  }

  Stream<List<ActivityModel>> watchActivitiesForDate(DateTime date) {
    final dateStr = _formatDate(date);

    final query =
        database.select(database.activities).join([
            leftOuterJoin(
              database.categories,
              database.categories.id.equalsExp(database.activities.categoryId),
            ),
          ])
          ..where(database.activities.date.equals(dateStr))
          ..orderBy([OrderingTerm.asc(database.activities.hour)]);

    return query.watch().map((results) {
      return results.map((row) {
        final activityEntity = row.readTable(database.activities);
        final categoryEntity = row.readTable(database.categories);
        return ActivityMapper.fromEntity(
          activityEntity,
          CategoryMapper.fromEntity(categoryEntity),
        );
      }).toList();
    });
  }

  Stream<List<ActivityModel>> watchTodayActivities() {
    return watchActivitiesForDate(DateTime.now());
  }

  Future<ActivityModel?> getActivityForHour({
    required DateTime date,
    required int hour,
  }) async {
    final dateStr = _formatDate(date);

    final query =
        database.select(database.activities).join([
            leftOuterJoin(
              database.categories,
              database.categories.id.equalsExp(database.activities.categoryId),
            ),
          ])
          ..where(database.activities.date.equals(dateStr))
          ..where(database.activities.hour.equals(hour));

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    final activityEntity = result.readTable(database.activities);
    final categoryEntity = result.readTable(database.categories);

    return ActivityMapper.fromEntity(
      activityEntity,
      CategoryMapper.fromEntity(categoryEntity),
    );
  }

  Future<List<int>> getOccupiedHours(DateTime date) async {
    final activities = await getActivitiesForDate(date);
    return activities.map((a) => a.hour).toList();
  }

  Future<Map<String, Map<CategoryModel, int>>> getWeeklyStats() async {
    final now = DateTime.now();
    final stats = <String, Map<CategoryModel, int>>{};

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      stats[dateStr] = await getCategoryStatsForDate(date);
    }

    return stats;
  }

  Future<List<ActivityModel>> getAllActivities({
    int? limit,
    int? offset,
  }) async {
    final query = database.select(database.activities).join([
      leftOuterJoin(
        database.categories,
        database.categories.id.equalsExp(database.activities.categoryId),
      ),
    ])..orderBy([OrderingTerm.desc(database.activities.timestamp)]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    final results = await query.get();

    return results.map((row) {
      final activityEntity = row.readTable(database.activities);
      final categoryEntity = row.readTable(database.categories);
      return ActivityMapper.fromEntity(
        activityEntity,
        CategoryMapper.fromEntity(categoryEntity),
      );
    }).toList();
  }

  Future<List<ActivityModel>> searchActivities(String query) async {
    final lowerQuery = '%${query.toLowerCase()}%';

    final searchQuery =
        database.select(database.activities).join([
            leftOuterJoin(
              database.categories,
              database.categories.id.equalsExp(database.activities.categoryId),
            ),
          ])
          ..where(database.activities.title.lower().like(lowerQuery))
          ..orderBy([OrderingTerm.desc(database.activities.timestamp)])
          ..limit(50);

    final results = await searchQuery.get();

    return results.map((row) {
      final activityEntity = row.readTable(database.activities);
      final categoryEntity = row.readTable(database.categories);
      return ActivityMapper.fromEntity(
        activityEntity,
        CategoryMapper.fromEntity(categoryEntity),
      );
    }).toList();
  }

  Future<int> deleteAllActivities() async {
    return await database.delete(database.activities).go();
  }

  Future<int> deleteOldActivities({int daysOld = 730}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch;

    return await (database.delete(database.activities)
      ..where((a) => a.timestamp.isSmallerThanValue(cutoffTimestamp))).go();
  }

  Future<int> getTotalCount() async {
    final query = database.selectOnly(database.activities)
      ..addColumns([database.activities.id.count()]);

    final result = await query.getSingle();
    return result.read(database.activities.id.count()) ?? 0;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<List<ActivityModel>> getActivitiesForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    int? offset,
    int? categoryId,
  }) async {
    final startTimestamp =
        DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        ).millisecondsSinceEpoch;

    final endTimestamp =
        DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        ).millisecondsSinceEpoch;

    final query =
        database.select(database.activities).join([
            leftOuterJoin(
              database.categories,
              database.categories.id.equalsExp(database.activities.categoryId),
            ),
          ])
          ..where(
            database.activities.timestamp.isBiggerOrEqualValue(startTimestamp),
          )
          ..where(
            database.activities.timestamp.isSmallerOrEqualValue(endTimestamp),
          );

    if (categoryId != null) {
      query.where(database.activities.categoryId.equals(categoryId));
    }

    query.orderBy([OrderingTerm.desc(database.activities.timestamp)]);

    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    final results = await query.get();

    return results.map((row) {
      final activityEntity = row.readTable(database.activities);
      final categoryEntity = row.readTable(database.categories);
      return ActivityMapper.fromEntity(
        activityEntity,
        CategoryMapper.fromEntity(categoryEntity),
      );
    }).toList();
  }

  Future<List<ActivityModel>> getCurrentWeekActivities() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return await getActivitiesForPeriod(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
  }

  Future<List<ActivityModel>> getCurrentMonthActivities() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return await getActivitiesForPeriod(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  Future<List<ActivityModel>> getLastNDaysActivities(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));

    return await getActivitiesForPeriod(startDate: startDate, endDate: now);
  }

  Future<Map<String, List<ActivityModel>>> getActivitiesByMonth({
    required int year,
    int? month,
  }) async {
    final activities = <String, List<ActivityModel>>{};

    if (month != null) {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);
      final monthActivities = await getActivitiesForPeriod(
        startDate: startDate,
        endDate: endDate,
      );
      final key = '${year}-${month.toString().padLeft(2, '0')}';
      activities[key] = monthActivities;
    } else {
      for (int m = 1; m <= 12; m++) {
        final startDate = DateTime(year, m, 1);
        final endDate = DateTime(year, m + 1, 0);
        final monthActivities = await getActivitiesForPeriod(
          startDate: startDate,
          endDate: endDate,
        );
        final key = '${year}-${m.toString().padLeft(2, '0')}';
        activities[key] = monthActivities;
      }
    }

    return activities;
  }

  Future<int> getActivitiesCountForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    int? categoryId,
  }) async {
    final startTimestamp =
        DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        ).millisecondsSinceEpoch;

    final endTimestamp =
        DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        ).millisecondsSinceEpoch;

    final query =
        database.selectOnly(database.activities)
          ..addColumns([database.activities.id.count()])
          ..where(
            database.activities.timestamp.isBiggerOrEqualValue(startTimestamp),
          )
          ..where(
            database.activities.timestamp.isSmallerOrEqualValue(endTimestamp),
          );

    if (categoryId != null) {
      query.where(database.activities.categoryId.equals(categoryId));
    }

    final result = await query.getSingle();
    return result.read(database.activities.id.count()) ?? 0;
  }

  Future<Map<CategoryModel, int>> getCategoryStatsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startTimestamp =
        DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        ).millisecondsSinceEpoch;

    final endTimestamp =
        DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        ).millisecondsSinceEpoch;

    final query =
        database.select(database.activities).join([
            leftOuterJoin(
              database.categories,
              database.categories.id.equalsExp(database.activities.categoryId),
            ),
          ])
          ..where(
            database.activities.timestamp.isBiggerOrEqualValue(startTimestamp),
          )
          ..where(
            database.activities.timestamp.isSmallerOrEqualValue(endTimestamp),
          );

    final results = await query.get();

    // Groups
    final stats = <int, int>{}; // categoryId -> count
    final categoriesMap = <int, CategoryModel>{}; // categoryId -> CategoryModel

    for (final row in results) {
      final activityEntity = row.readTable(database.activities);
      final categoryEntity = row.readTable(database.categories);
      final categoryId = activityEntity.categoryId;

      stats[categoryId] = (stats[categoryId] ?? 0) + 1;
      if (!categoriesMap.containsKey(categoryId)) {
        categoriesMap[categoryId] = CategoryMapper.fromEntity(categoryEntity);
      }
    }

    return Map.fromEntries(
      stats.entries.map((e) => MapEntry(categoriesMap[e.key]!, e.value)),
    );
  }
}
